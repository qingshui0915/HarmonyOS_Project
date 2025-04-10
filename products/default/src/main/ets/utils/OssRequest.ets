

let ossData: OssData= {
  key: this.ossPolicyToken.data.dir,
  policy: this.ossPolicyToken.data.policy,
  OSSAccessKeyId:this.ossPolicyToken.data.accessid,
  signature: this.ossPolicyToken.data.signature,
  success_action_status:'200'
}

export function upLoadFile(type,file,)




interface OssData {
  key: string,
  policy: string,
  OSSAccessKeyId:string,
  signature: string,
  success_action_status:string
}