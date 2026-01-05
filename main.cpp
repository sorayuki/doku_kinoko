#include <windows.h>
#include <iostream>
#include "doku.h"

// Globals
GLEnv g_glEnv;
RenderDoku g_renderDoku;
bool g_running = true;

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
    case WM_SIZE:
        g_renderDoku.Resize(LOWORD(lParam), HIWORD(lParam));
        break;
    case WM_CLOSE:
        g_running = false;
        PostQuitMessage(0);
        break;
    case WM_KEYDOWN:
        if (wParam == VK_ESCAPE) {
            g_running = false;
            PostQuitMessage(0);
        }
        break;
    case WM_ERASEBKGND:
        return 1; // Prevent flickering
    default:
        return DefWindowProc(hwnd, msg, wParam, lParam);
    }
    return 0;
}

int main() {
    std::cout << "Starting doku..." << std::endl;

    HINSTANCE hInstance = GetModuleHandle(nullptr);
    const char* className = "DokuWindowClass";
    
    WNDCLASS wc = {};
    wc.lpfnWndProc = WndProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = className;
    wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
    
    if (!RegisterClass(&wc)) {
        std::cerr << "Failed to register window class" << std::endl;
        return 1;
    }

    HWND hwnd = CreateWindow(
        className,
        "Doku Native",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 800, 600,
        nullptr,
        nullptr,
        hInstance,
        nullptr
    );

    if (!hwnd) {
        std::cerr << "Failed to create window" << std::endl;
        return 1;
    }

    if (!g_glEnv.Init(hwnd)) {
        std::cerr << "Failed to initialize generic GL environment" << std::endl;
        return 1;
    }

    g_renderDoku.Init();

    // Initial resize to set viewport
    RECT rect;
    GetClientRect(hwnd, &rect);
    g_renderDoku.Resize(rect.right - rect.left, rect.bottom - rect.top);

    ShowWindow(hwnd, SW_SHOW);
    UpdateWindow(hwnd);

    MSG msg = {};
    
    DWORD fpsTime = GetTickCount();
    int frameCount = 0;
    int fpsHistory[3] = {0, 0, 0};

    while (g_running) {
        while (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
            if (msg.message == WM_QUIT) {
                g_running = false;
            }
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }

        if (g_running) {
            g_renderDoku.Tick();
            g_renderDoku.Render();
            g_glEnv.Swap();

            frameCount++;
            DWORD currentTime = GetTickCount();
            if (currentTime - fpsTime >= 1000) {
                // Shift history
                fpsHistory[0] = fpsHistory[1];
                fpsHistory[1] = fpsHistory[2];
                fpsHistory[2] = frameCount;

                float weightedAvg = (float)(fpsHistory[2] * 4 + fpsHistory[1] * 2 + fpsHistory[0] * 1) / 7.0f;
                
                char title[256];
                sprintf_s(title, "Doku Native - FPS: %.2f", weightedAvg);
                SetWindowText(hwnd, title);

                fpsTime = currentTime;
                frameCount = 0;
            }
        }
    }

    g_glEnv.Destroy();
    return 0;
}
