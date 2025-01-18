// import {
//   BarcodeFormat,
//   MultiFormatWriter,
//   BitMatrix,
//   EncodeHintType,
//   MultiFormatReader,
//   DecodeHintType,
//   RGBLuminanceSource,
//   BinaryBitmap,
//   HybridBinarizer
// } from '@ohos/zxing';
// import image from '@ohos.multimedia.image';
//
// export default class QRCodes {
//   async encode(content: string, width: number, height: number): Promise<image.PixelMap> {
//     const hints:Map<EncodeHintType , number> = new Map();
//     hints.set(EncodeHintType.MARGIN, 0);
//     const writer = new MultiFormatWriter();
//     const matrix = writer.encode(content, BarcodeFormat.QR_CODE, width, height, hints);
//     const pixelData = this.getMatrixPixelData(matrix, width, height);
//     return await image.createPixelMap(pixelData.buffer, { size: { width, height } });
//   }
//
//   async decode(pixelMap: image.PixelMap, width: number, height: number): Promise<string> {
//     const buffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
//     await pixelMap.readPixelsToBuffer(buffer);
//     const int32Array = new Int32Array(buffer);
//     const luminanceSource = new RGBLuminanceSource(int32Array, width, height);
//     const binaryBitmap = new BinaryBitmap(new HybridBinarizer(luminanceSource));
//     const reader = new MultiFormatReader();
//     const hints:Map<DecodeHintType , number[]> = new Map();
//     hints.set(DecodeHintType.POSSIBLE_FORMATS, [BarcodeFormat.QR_CODE]);
//     const result = reader.decode(binaryBitmap, hints);
//     return result.getText();
//   }
//
//   private getMatrixPixelData(matrix: BitMatrix, width: number, height: number): Uint32Array {
//     const BLACK = 0xFF000000;
//     const WHITE = 0xFFFFFFFF;
//     const pixels = new Uint32Array(width * height);
//     for (let y = 0; y < height; y++) {
//       const offset = y * width;
//       for (let x = 0; x < width; x++) {
//         pixels[offset + x] = matrix.get(x, y) ? BLACK : WHITE;
//       }
//     }
//     return pixels;
//   }
// }
