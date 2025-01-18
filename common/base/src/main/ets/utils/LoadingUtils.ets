import { PkLoadingManager } from '@peakmain/library/Index';

export class LoadingUtils {
  private static loadingManager: PkLoadingManager ;

  // 初始化加载管理器
  public static init(uiContext: UIContext) {
    if (!LoadingUtils.loadingManager) {
      LoadingUtils.loadingManager = new PkLoadingManager(uiContext);
    }
  }

  // 显示加载Loading框
  public static showLoading(title: string = "加载中...") {
    if (LoadingUtils.loadingManager) {
      LoadingUtils.loadingManager.setTitle(title).open();
    } else {
      console.error("LoadingManager is not initialized. Call init() first.");
    }
  }

  // 隐藏加载Loading框
  public static hideLoading() {
    if (LoadingUtils.loadingManager) {
      LoadingUtils.loadingManager.close();
    } else {
      console.error("LoadingManager is not initialized. Call init() first.");
    }
  }
}