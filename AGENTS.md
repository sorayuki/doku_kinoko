# 项目说明

一个原生应用，将 dumogu_web.htm 移植为原生应用

# TODO列表

[ ] 通过 dir /s/b 或等效命令查看当前文件夹结构
[ ] 创建 doku.h 和 doku.cpp 文件并加入到 CMakeLists.txt 中
[ ] 创建 main.cpp，并将这三个代码文件编译为可执行文件 doku
[ ] main.cpp 中添加创建最简单的窗口的功能，并屏蔽 WM_ERASEBKGND 消息
[ ] 可执行文件 doku 依赖 ANGLE 库，添加 ANGLE 库的头文件和链接库依赖，适配 DEBUG 和 RELEASE 模式，并能在编译的时候自动复制 DLL 到可执行文件所在位置
[ ] 在 doku 源码文件添加 GLEnv 类，用于管理 OpenGL 上下文。类包括初始化 EGL 环境、创建 OpenGL ES 3.2 上下文、创建 Surface 等
[ ] 在 doku 源码文件添加 RenderDoku 类，包含 Init Tick Render Destroy 等方法；移植 dumogu_web.htm 中的渲染逻辑到 RenderDoku 中
[ ] 集成上述逻辑，使程序可以运行，并显示 dumogu_web.htm 中利用 WebGL 渲染的内容
