#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Web界面功能测试脚本
"""

import requests
import json
import time

def test_web_interface():
    """测试Web界面的基本功能"""
    base_url = "http://localhost:5000"
    
    print("🧪 开始测试Web界面功能...")
    
    try:
        # 测试主页访问
        print("1. 测试主页访问...")
        response = requests.get(base_url, timeout=5)
        if response.status_code == 200:
            print("   ✅ 主页访问成功")
        else:
            print(f"   ❌ 主页访问失败: {response.status_code}")
            return False
        
        # 测试容器状态API
        print("2. 测试容器状态API...")
        response = requests.get(f"{base_url}/api/container/status", timeout=10)
        if response.status_code == 200:
            status = response.json()
            print(f"   ✅ 状态API响应成功: {status}")
        else:
            print(f"   ❌ 状态API失败: {response.status_code}")
            return False
        
        # 测试启动容器API（如果容器存在且未运行）
        if status.get('exists') and not status.get('running'):
            print("3. 测试启动容器API...")
            response = requests.post(f"{base_url}/api/container/start", timeout=30)
            if response.status_code == 200:
                result = response.json()
                print(f"   ✅ 启动API响应: {result}")
            else:
                print(f"   ❌ 启动API失败: {response.status_code}")
        
        # 测试部署API（谨慎使用）
        print("4. 跳过部署测试（避免重复部署）")
        
        print("\n🎉 Web界面基本功能测试完成！")
        return True
        
    except requests.exceptions.ConnectionError:
        print("❌ 无法连接到Web服务器，请确保服务器正在运行")
        return False
    except Exception as e:
        print(f"❌ 测试过程中出现错误: {e}")
        return False

def check_dependencies():
    """检查依赖是否安装"""
    print("🔍 检查依赖...")
    
    try:
        import flask
        import flask_socketio
        print(f"   ✅ Flask: {flask.__version__}")
        print(f"   ✅ Flask-SocketIO: {flask_socketio.__version__}")
        return True
    except ImportError as e:
        print(f"   ❌ 缺少依赖: {e}")
        print("   请运行: pip install -r requirements.txt")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("🚀 Docker沙箱Web界面测试工具")
    print("=" * 50)
    
    if not check_dependencies():
        exit(1)
    
    print("\n请确保Web服务器正在运行 (python app.py)")
    input("按Enter键开始测试...")
    
    if test_web_interface():
        print("\n✅ 所有测试通过！Web界面工作正常。")
    else:
        print("\n❌ 测试失败，请检查Web服务器状态。")