import webView from '@ohos.web.webview'
import { router } from '@kit.ArkUI';
import { HdNav } from 'base';

@Entry
@Component
struct Pages_WebView {
  @State  url:string = "";
  @State title:string|undefined = "";

  controller: webView.WebviewController = new webView.WebviewController()

  aboutToAppear(): void {
    let  params = router.getParams() as Record<string,Object>
    this.url=params["url"] as string;
    // this.title=params["title"] as Resource;
    console.log("传递过来的url："+this.url)
  }

  build() {
    Column() {
      HdNav({
        title:this.title
      })
      //
      Web({
        src: "https://testh5.hnxzkj.cn/otherPages/pages/rich-text/rich-text?code=UserPrivacyPolicy",
        controller: this.controller})
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onTitleReceive((event) => {
          this.title = event?.title;
        }).layoutWeight(1)

    }

    .justifyContent(FlexAlign.Start)
  }
}