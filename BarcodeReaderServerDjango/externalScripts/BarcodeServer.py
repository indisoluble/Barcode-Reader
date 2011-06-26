import sys, traceback, Ice
import Demo

class BarcodeI(Demo.Barcode):
    def priceForBarcode(self, bc, current=None):
        print "Barcode received <<" + bc + ">>"
        return -1


status = 0
ic = None
try:
    ic = Ice.initialize(sys.argv)
    adapter = ic.createObjectAdapterWithEndpoints("BarcodeAdapter", "default -p 10000")
    object = BarcodeI()
    adapter.add(object, ic.stringToIdentity("BarcodeRemoteDB"))
    adapter.activate()
    ic.waitForShutdown()
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
