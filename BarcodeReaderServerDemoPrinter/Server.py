import sys, traceback, Ice
import Demo

class PrinterI(Demo.Printer):
	def printString(self, s, current=None):
		print s

status = 0
ic = None
try:
	ic = Ice.initialize(sys.argv)
	adapter = ic.createObjectAdapterWithEndpoints("SimplePrinterAdapter", "default -p 10000")
	object = PrinterI()
	adapter.add(object, ic.stringToIdentity("SimplePrinter"))
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
