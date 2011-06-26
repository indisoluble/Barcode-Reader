import sys, traceback, Ice
import Demo

status = 0
ic = None
try:
    ic = Ice.initialize(sys.argv)
    base = ic.stringToProxy("BarcodeRemoteDB:default -p 10000")
    barcodeDB = Demo.BarcodePrx.checkedCast(base)
    if not barcodeDB:
        raise RuntimeError("Invalid proxy")
    
    print "Price for 9788403504455 ==> %d" % barcodeDB.priceForBarcode("9788403504455")
    print "Price for 3543790305070 ==> %d" % barcodeDB.priceForBarcode("3543790305070")
except:
    traceback.print_exc()
    status = 1

if ic:
    # Clean up
    try:
        ic.destroy()
    except:
        traceback.print_exc()
        status = 1

sys.exit(status)
