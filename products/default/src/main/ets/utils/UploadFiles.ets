import { MMKV } from "@tencent/mmkv";
import { Api, NetConstants } from "base";
import { putObject } from "./upload";

export class UploadFiles {
  /**
   * 上传图片到OSS
   * @param uri 图片本地URI
   * @returns 返回上传后的图片URL
   */
  public async uploadImage(uri: string): Promise<string> {
    // 获取access token
    let access_token: string = MMKV.defaultMMKV().decodeString("Token") || "";
    if (access_token === "" || !access_token) {
      access_token = "";
    }
    // 获取文件名
    const fileNameData = await Api.net().getOssFileNameRequest();
    const name = fileNameData.data?.data;
    const fileName = `${name}.jpg`;
    const fileType = "image/jpeg";
    // 获取签名
    const SignatureData = await Api.net().getOssParamRequest(fileName, fileType);
    const SignatureUrl = SignatureData.data?.data as string;

    // 上传文件
    const result = await putObject(uri, fileType, SignatureUrl, fileName);
    const imageUrl = `${NetConstants.OSSPoint}/${fileName}`;

    return imageUrl;
  }
}

