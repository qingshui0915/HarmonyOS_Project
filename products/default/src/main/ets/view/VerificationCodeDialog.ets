@CustomDialog
export struct VerificationCodeDialog {

  @Link ImagesUri: string //base64图片值
  swapItOut?: () => void //换一换回调方法
  confirm?: (str:string) => void //完成图片验证码回调方法
  controller: CustomDialogController = new CustomDialogController({
    builder: VerificationCodeDialog({
      ImagesUri:this.ImagesUri//接收Link
    }),
  })
  aboutToAppear(): void {
    console.log(JSON.stringify(this.ImagesUri))
  }

  build() {
    Column(){
      Row({space:10}){
        Image(this.ImagesUri)
          .width(150)
          .height(40)
          .objectFit(ImageFit.Auto)
        Text("换一换")
          .fontColor($r("app.color.text_color1"))
          .fontSize(16)
          .width(120)
          .height(40)
          .textAlign(TextAlign.Center)
          .margin({left:30})
          .onClick(()=>{
            //传递事件  这里弹框不收起不掉close()
            if (this.swapItOut != undefined) {
              this.swapItOut()
            }
          })
      }
      .width("100%")
      .alignItems(VerticalAlign.Center)

      Row(){
        TextInput({
          placeholder: "请输入图形验证码"
        })
          .fontSize(15)
          .fontColor($r("app.color.text_h1"))
          .type(InputType.Number)
          .onChange((value:string)=>{
            if (value.length == 4) {
              // console.log("图形验证码==="+value)
              if (this.confirm != undefined) {
                this.confirm(value)
                this.controller.close()
              }
            }
          })
      }
      .width("100%")
      .margin({top:18})
    }
    .padding(25)
  }
}