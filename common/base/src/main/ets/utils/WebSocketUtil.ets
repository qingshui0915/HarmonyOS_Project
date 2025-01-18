import { webSocket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

class WebSocketUtil {
  private ws: webSocket.WebSocket;
  private url: string;
  private onMessageCallback: (message: string | ArrayBuffer) => void;
  private onCloseCallback: (code: number, reason: string) => void;
  private onErrorCallback: (error: BusinessError) => void;
  private heartbeatInterval: number = 30000; // 心跳间隔，默认 30 秒
  private heartbeatTimer: number | null = null; // 心跳定时器
  private lastPongTime: number = Date.now(); // 最后一次收到服务器心跳响应的时间
  private reconnectAttempts: number = 0; // 重连尝试次数
  private maxReconnectAttempts: number = 5; // 最大重连尝试次数

  constructor(url: string) {
    this.url = url;
    this.ws = webSocket.createWebSocket();
    this.onMessageCallback = () => {};
    this.onCloseCallback = () => {};
    this.onErrorCallback = () => {};
    this.initWebSocket();
  }

  private initWebSocket(): void {
    this.ws.on('open', (err: BusinessError, value: Object) => {
      if (err) {
        console.log("WebSocket open error: " + JSON.stringify(err));
      } else {
        console.log("WebSocket opened successfully");
        this.startHeartbeat(); // 连接成功后启动心跳
        this.reconnectAttempts = 0; // 重置重连尝试次数
      }
    });

    this.ws.on('message', (err: BusinessError, value: string | ArrayBuffer) => {
      if (err) {
        console.log("WebSocket message error: " + JSON.stringify(err));
      } else {
        console.log("WebSocket message received: " + value);
        this.onMessageCallback(value);

        // 如果收到服务器的心跳响应，更新最后一次收到响应的时间
        if (value === 'pong') {
          this.lastPongTime = Date.now();
        }
      }
    });

    this.ws.on('close', (err: BusinessError, value: webSocket.CloseResult) => {
      if (err) {
        console.log("WebSocket close error: " + JSON.stringify(err));
      } else {
        console.log("WebSocket closed, code: " + value.code + ", reason: " + value.reason);
        this.onCloseCallback(value.code, value.reason);
      }

      // 连接关闭后尝试重连
      this.handleReconnect();
    });

    this.ws.on('error', (err: BusinessError) => {
      console.log("WebSocket error: " + JSON.stringify(err));
      this.onErrorCallback(err);

      // 发生错误后尝试重连
      this.handleReconnect();
    });
  }

  // 启动心跳
  private startHeartbeat(): void {
    this.stopHeartbeat(); // 先停止之前的心跳

    // 使用显式类型断言将返回值转换为 number
    this.heartbeatTimer = setInterval(() => {
      // 检查是否超过最大重连尝试次数
      if (this.reconnectAttempts >= this.maxReconnectAttempts) {
        console.log("Max reconnection attempts reached. Stopping heartbeat.");
        this.stopHeartbeat();
        return;
      }

      // 检查是否超时（例如，超过 2 倍心跳间隔未收到响应）
      if (Date.now() - this.lastPongTime > this.heartbeatInterval * 2) {
        console.log("Heartbeat timeout. Reconnecting...");
        this.handleReconnect();
        return;
      }

      // 发送心跳消息
      this.send("ping");
    }, this.heartbeatInterval) as number; // 直接断言为 number 类型
  }

  // 停止心跳
  private stopHeartbeat(): void {
    if (this.heartbeatTimer !== null) {
      clearInterval(this.heartbeatTimer);
      this.heartbeatTimer = null;
    }
  }

  // 处理重连
  private handleReconnect(): void {
    this.stopHeartbeat(); // 停止心跳
    this.reconnectAttempts++;

    if (this.reconnectAttempts <= this.maxReconnectAttempts) {
      console.log(`Reconnecting... Attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts}`);
      setTimeout(() => {
        this.connect();
      }, 5000); // 5 秒后重连
    } else {
      console.log("Max reconnection attempts reached. Giving up.");
    }
  }

  public connect(): void {
    this.ws.connect(this.url, (err: BusinessError, value: boolean) => {
      if (err) {
        console.log("WebSocket connection failed: " + JSON.stringify(err));
      } else {
        console.log("WebSocket connected successfully");
      }
    });
  }

  public send(message: string): void {
    this.ws.send(message, (err: BusinessError, value: boolean) => {
      if (err) {
        console.log("Failed to send message: " + JSON.stringify(err));
      } else {
        console.log("Message sent successfully");
      }
    });
  }

  public close(): void {
    this.stopHeartbeat(); // 关闭连接时停止心跳
    this.ws.close((err: BusinessError, value: boolean) => {
      if (err) {
        console.log("Failed to close WebSocket: " + JSON.stringify(err));
      } else {
        console.log("WebSocket closed successfully");
      }
    });
  }

  public setOnMessageCallback(callback: (message: string | ArrayBuffer) => void): void {
    this.onMessageCallback = callback;
  }

  public setOnCloseCallback(callback: (code: number, reason: string) => void): void {
    this.onCloseCallback = callback;
  }

  public setOnErrorCallback(callback: (error: BusinessError) => void): void {
    this.onErrorCallback = callback;
  }
}

export default WebSocketUtil;