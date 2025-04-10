import { fileSelect, photoSelect } from './fileSelect';
import { putObject } from './upload';
import { DateUtils ,Api } from 'base'
import { NetConstants } from 'base/src/main/ets/constants/NetConstants';
import { MMKV } from '@tencent/mmkv';

@Entry
@Component
struct XCUploadFile {

  putObject = async (uri:string) =>{
    let access_token:string = MMKV.defaultMMKV().decodeString("Token") || ""
    if (access_token == "" || !access_token) {
      access_token = ""
    }
    //获取文件名
    const fileNameData = await Api.net().getOssFileNameRequest()
    const name = fileNameData.data?.data
    const fileName = `${name}.jpg`
    const fileType = "image/jpeg"

    //获取签名
    const SignatureData = await Api.net().getOssParamRequest(fileName ,fileType)
    const SignatureUrl = fileNameData.data?.data as string

    //上传
    const result = await putObject(uri ,fileType ,SignatureUrl ,fileName)
    const imageUrl = `${NetConstants.OSSPoint}/${fileName}`;
    console.log(`图片地址 === ` + imageUrl)

  }


  build() {
    Row() {
      Column() {
        Button(){
          Text('Upload File').fontSize('30').fontColor('white')
        }.margin({
          top: 30
        })
        .height('5%')
        .width('50%')
        .onClick(() => {
          console.info('onClick');
          const context = getContext(this);

          //图片上传
          photoSelect(5, context).then(((photoSelectResult) =>{
            const array:Array<string> = photoSelectResult.photoUris
            array.forEach(element => {
              console.log(`local image uri == ${element}`)
            });

            this.putObject(array[0])

          })).then(error =>{
            console.log("")
          })


        })
      }
      .width('100%')
    }
    .height('100%')
  }
}