# AAC

AAC(Advanced Audio Coding，高级音频编码)是一种声音数据的文件压缩格式，又分为 ADIF 和 ADTS 两种格式。

ADIF：Audio Data Interchange Format 音频数据交换格式；只有文件的开始处有 header 字节，解码只能在头字节处开始进行，常用在磁盘文件中。

ADTS：Audio Data Transport Stream 音频数据传输流；每一单元音频数据都有一个 header 字节，任何一个音频数据都可以单独解码。



