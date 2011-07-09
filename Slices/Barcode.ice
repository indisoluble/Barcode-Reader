module Demo {

    sequence<byte> ByteSeq;

    interface Barcode {
        int priceForBarcode(string code);
        int saveProduct(string bc, string desc, int price, ByteSeq image);
    };
};
