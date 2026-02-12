#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Docker沙箱Web管理界面
提供Web终端和容器管理功能
"""

import os
import subprocess
import json
import asyncio
import websockets
import threading
from flask import Flask, render_template, jsonify, request
from flask_socketio import SocketIO, emit

# Linux平台终端支持
import pty
import select
import termios
import struct
import fcntl

app = Flask(__name__)
app.config['SECRET_KEY'] = 'sandbox-web-interface-secret'
socketio = SocketIO(app, cors_allowed_origins="*", logger=True, engineio_logger=True)

# 全局变量存储终端进程
terminal_processes = {}

class DockerManager:
    """Docker容器管理类"""
    
    @staticmethod
    def get_container_status():
        """获取secure-sandbox容器状态"""
        try:
            # Linux环境直接执行Docker命令
            result = subprocess.run(
                ['docker', 'ps', '-a', '--filter', 'name=secure-sandbox', '--format', 'json'],
                capture_output=True, text=True, check=True
            )
            
            if result.stdout.strip():
                container_info = json.loads(result.stdout.strip())
                return {
                    'exists': True,
                    'running': container_info['State'] == 'running',
                    'status': container_info['State'],
                    'name': container_info['Names'],
                    'image': container_info['Image'],
                    'created': container_info['CreatedAt']
                }
            else:
                return {'exists': False, 'running': False}
        except subprocess.CalledProcessError as e:
            return {'error': f'Docker命令执行失败: {e}'}
        except json.JSONDecodeError:
            return {'error': 'Docker输出解析失败'}
    
    @staticmethod
    def start_container():
        """启动容器"""
        try:
            subprocess.run(['docker', 'start', 'secure-sandbox'], check=True)
            return {'success': True, 'message': '容器启动成功'}
        except subprocess.CalledProcessError as e:
            return {'success': False, 'message': f'容器启动失败: {e}'}
    
    @staticmethod
    def stop_container():
        """停止容器"""
        try:
            subprocess.run(['docker', 'stop', 'secure-sandbox'], check=True)
            return {'success': True, 'message': '容器停止成功'}
        except subprocess.CalledProcessError as e:
            return {'success': False, 'message': f'容器停止失败: {e}'}
    
    @staticmethod
    def deploy_sandbox():
        """部署沙箱"""
        try:
            # 切换到项目根目录
            project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            deploy_script = os.path.join(project_root, 'deploy.sh')
            
            # 确保脚本有执行权限
            os.chmod(deploy_script, 0o755)
            
            # Linux环境直接执行
            result = subprocess.run(
                ['bash', deploy_script], 
                cwd=project_root,
                capture_output=True, 
                text=True, 
                check=True,
                timeout=300  # 5分钟超时
            )
            return {'success': True, 'message': '沙箱部署成功', 'output': result.stdout}
        except subprocess.TimeoutExpired:
            return {'success': False, 'message': '部署超时，请检查Docker服务和网络连接'}
        except subprocess.CalledProcessError as e:
            error_msg = e.stderr if e.stderr else str(e)
            return {'success': False, 'message': f'沙箱部署失败: {error_msg}', 'output': e.stdout}
        except Exception as e:
            return {'success': False, 'message': f'部署过程出错: {str(e)}'}

@app.route('/')
def index():
    """主页"""
    return render_template('index.html')

@app.route('/record_registration')
def record_registration():
    """备案登记页面"""
    return render_template('record_registration.html')

@app.route('/api/container/status')
def container_status():
    """获取容器状态API"""
    return jsonify(DockerManager.get_container_status())

@app.route('/api/container/start', methods=['POST'])
def start_container():
    """启动容器API"""
    return jsonify(DockerManager.start_container())

@app.route('/api/container/stop', methods=['POST'])
def stop_container():
    """停止容器API"""
    return jsonify(DockerManager.stop_container())

@app.route('/api/container/deploy', methods=['POST'])
def deploy_container():
    """部署容器API"""
    return jsonify(DockerManager.deploy_sandbox())

@socketio.on('connect')
def handle_connect():
    """WebSocket连接处理"""
    print('客户端已连接')
    emit('connected', {'data': '连接成功'})

@socketio.on('disconnect')
def handle_disconnect():
    """WebSocket断开处理"""
    print('客户端已断开连接')
    # 清理终端进程
    session_id = request.sid
    if session_id in terminal_processes:
        try:
            terminal_processes[session_id]['process'].terminate()
            del terminal_processes[session_id]
        except:
            pass

@socketio.on('start_terminal')
def handle_start_terminal():
    """启动终端会话"""
    session_id = request.sid
    print(f"[{session_id}] 收到启动终端的请求")

    if session_id in terminal_processes:
        print(f"[{session_id}] 终端已经存在，正在清理旧的进程...")
        # 清理旧的进程资源
        proc_info = terminal_processes.pop(session_id, None)
        if proc_info:
            try:
                os.close(proc_info['fd'])
                # 可以在这里添加 kill 进程的逻辑
            except OSError as e:
                print(f"[{session_id}] 关闭旧fd时出错: {e}")

    try:
        # 创建一个伪终端
        pid, fd = pty.fork()
    except Exception as e:
        print(f"[{session_id}] pty.fork() 失败: {e}")
        emit('terminal_error', {'error': f'创建终端失败: {e}'})
        return

    if pid == 0:  # 子进程
        # 在子进程中，我们启动一个 shell
        print(f"[Child {os.getpid()}] 正在启动 shell...")
        try:
            # 启动一个交互式的 shell
            subprocess.run(['docker', 'exec', '-it', 'secure-sandbox', '/bin/sh'])
        except FileNotFoundError:
            print(f"[Child {os.getpid()}] Docker 命令未找到!")
            os._exit(1)
        except Exception as e:
            print(f"[Child {os.getpid()}] exec 失败: {e}")
            os._exit(1)
        # exec 后，这里的代码不应执行
        os._exit(0)

    else:  # 父进程
        print(f"[{session_id}] 伪终端创建成功，PID: {pid}, FD: {fd}")
        terminal_processes[session_id] = {'pid': pid, 'fd': fd}

        # 设置终端大小
        try:
            set_winsize(fd, 24, 80)
        except Exception as e:
            print(f"[{session_id}] 设置终端大小失败: {e}")

        # 创建一个后台任务来读取 pty 的输出
        def read_and_forward_output():
            max_read_bytes = 1024 * 20
            print(f"[{session_id}] 开始读取终端输出...")
            while session_id in terminal_processes:
                try:
                    # 使用 select 来检查 fd 是否可读，设置一个小的超时
                    socketio.sleep(0.01)
                    ready, _, _ = select.select([fd], [], [], 0)
                    if ready:
                        output = os.read(fd, max_read_bytes)
                        if output:
                            # 解码并发送到前端
                            decoded_output = output.decode('utf-8', errors='ignore')
                            # print(f"[{session_id}] 发送输出: {repr(decoded_output)}") # 用于调试
                            socketio.emit('terminal_output', {'data': decoded_output})
                        else:
                            # 读取到空内容，意味着子进程可能已退出
                            print(f"[{session_id}] 读取到 EOF，终端会话结束。")
                            break
                except OSError as e:
                    print(f"[{session_id}] 读取 PTY 时出错: {e}")
                    break
                except Exception as e:
                    print(f"[{session_id}] 在读取循环中发生未知错误: {e}")
                    break
            
            print(f"[{session_id}] 输出读取任务结束。")
            # 清理资源
            proc_info = terminal_processes.pop(session_id, None)
            if proc_info:
                try:
                    os.close(proc_info['fd'])
                except OSError as e:
                    print(f"[{session_id}] 关闭fd时出错: {e}")
            emit('terminal_output', {'data': '\r\n[会话结束]\r\n'})


        socketio.start_background_task(target=read_and_forward_output)
        emit('terminal_started', {'success': True})
        print(f"[{session_id}] 终端启动流程完成。")


def set_winsize(fd, rows, cols):
    """设置终端窗口大小"""
    winsize = struct.pack('HHHH', rows, cols, 0, 0)
    fcntl.ioctl(fd, termios.TIOCSWINSZ, winsize)

@socketio.on('terminal_input')
def handle_terminal_input(data):
    """处理终端输入"""
    session_id = request.sid
    if session_id in terminal_processes:
        fd = terminal_processes[session_id]['fd']
        try:
            input_data = data.get('data', '')
            if input_data:
                # print(f"[{session_id}] 收到输入: {repr(input_data)}") # 用于调试
                os.write(fd, input_data.encode('utf-8'))
        except OSError as e:
            print(f"[{session_id}] 写入 PTY 时出错: {e}")
            # 可以选择在这里结束会话
        except Exception as e:
            print(f"[{session_id}] 处理输入时发生未知错误: {e}")

@socketio.on('terminal_resize')
def handle_terminal_resize(data):
    """处理终端大小调整"""
    session_id = request.sid
    
    if session_id in terminal_processes:
        try:
            master = terminal_processes[session_id]['master']
            rows = data.get('rows', 24)
            cols = data.get('cols', 80)
            
            # 设置终端大小
            fcntl.ioctl(master, termios.TIOCSWINSZ, 
                       struct.pack('HHHH', rows, cols, 0, 0))
        except Exception as e:
            print(f'终端大小调整失败: {e}')

if __name__ == '__main__':
    print("启动Docker沙箱Web管理界面...")
    print("访问地址: http://localhost:5000")
    socketio.run(app, host='0.0.0.0', port=5000, debug=True)