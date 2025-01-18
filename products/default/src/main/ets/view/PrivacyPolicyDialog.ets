import { router } from '@kit.ArkUI'

@Component
export default struct PrivacyPolicyDialog{
    cancel?: () => void
    confirm?: () => void

    build() {
        Stack(){
            Column() {
                Text($r('app.string.simple_user_policy')).fontSize(18).fontColor($r('app.color.title_color')).margin({ top: 30, bottom: 19 })

                Scroll(){
                    Text(){
                        Span($r('app.string.privacy_policy_start'))
                        Span($r('app.string.simple_privacy_policy'))
                    }.fontSize(16).fontColor($r('app.color.body_color')).margin({
                        left:25,
                        right:25
                    })
                }.height(120)

                Column(){
                    Button($r('app.string.disagree_privacy_policy')).onClick(() => {
                        if (this.cancel!=undefined) {
                            this.cancel();
                        }

                    }).fontColor($r('app.color.other_color')).fontSize(15).backgroundColor(Color.Transparent)

                    Button($r('app.string.agree_privacy_policy')).onClick(() => {
                        if (this.confirm!=undefined) {
                            this.confirm();
                        }
                    }).fontColor($r('app.color.white')).fontSize(17)
                        .linearGradient({
                            direction: GradientDirection.Right, colors:[[$r('app.color.color_shubihong'),0.0],[$r('app.color.color_shubihong'),1.0]]
                        }).width('80%').margin({
                        top:15,bottom:21
                    }).borderRadius(24)
                }
            }
            .backgroundColor($r('app.color.white'))
            .borderRadius(13)
            .width('80%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor("#4D000000")//黑色背景 透明度约为 30%
    }
}