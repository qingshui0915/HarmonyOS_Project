import { Logger, showToast } from "base";
import { camera, cameraPicker } from "@kit.CameraKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { picker } from "@kit.CoreFileKit";

/**
 * 相册和拍照工具类
 * @returns
 */
export async function fileSelect(): Promise<string> {
  let photoSelectOptions = new picker.PhotoSelectOptions();
  photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
  photoSelectOptions.maxSelectNumber = 1;
  let photoPicker = new picker.PhotoViewPicker();
  try {
    let photoSelectResult = await photoPicker.select(photoSelectOptions);
    if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
      let imgUri = photoSelectResult.photoUris[0];
      if (imgUri.indexOf('media/Photo')<0) {
        showToast('打印图片');
        return '';
      }
      return photoSelectResult.photoUris[0];
    } else {
      return '';
    }
  } catch (err) {
    Logger.error('SelectedImage failed', JSON.stringify(err));
    return '';
  }
}

export async function cameraSelect(cameraPosition: Array<camera.CameraPosition>,
  mediaType: Array<cameraPicker.PickerMediaType>,context:Context): Promise<string> {
  try {
    let pickerProfile: cameraPicker.PickerProfile = { cameraPosition: cameraPosition[1] };
    let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(context,
      [mediaType[0]], pickerProfile);
    let uri = pickerResult.resultUri;
    return uri;
    // hilog.info(0x0000, ' ', "the pick pickerResult is:" + JSON.stringify(pickerResult));
  } catch (error) {
    let err = error as BusinessError;
    Logger.error( `the pick call failed. error code: `);
    return '';
  }

}