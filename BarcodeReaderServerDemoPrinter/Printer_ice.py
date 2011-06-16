# **********************************************************************
#
# Copyright (c) 2003-2009 ZeroC, Inc. All rights reserved.
#
# This copy of Ice is licensed to you under the terms described in the
# ICE_LICENSE file included in this distribution.
#
# **********************************************************************

# Ice version 3.3.1
# Generated from file `Printer.ice'

import Ice, IcePy, __builtin__

if not Ice.__dict__.has_key("_struct_marker"):
    Ice._struct_marker = object()

# Start of module Demo
_M_Demo = Ice.openModule('Demo')
__name__ = 'Demo'

if not _M_Demo.__dict__.has_key('Printer'):
    _M_Demo.Printer = Ice.createTempClass()
    class Printer(Ice.Object):
        def __init__(self):
            if __builtin__.type(self) == _M_Demo.Printer:
                raise RuntimeError('Demo.Printer is an abstract class')

        def ice_ids(self, current=None):
            return ('::Demo::Printer', '::Ice::Object')

        def ice_id(self, current=None):
            return '::Demo::Printer'

        def ice_staticId():
            return '::Demo::Printer'
        ice_staticId = staticmethod(ice_staticId)

        #
        # Operation signatures.
        #
        # def printString(self, s, current=None):

        def __str__(self):
            return IcePy.stringify(self, _M_Demo._t_Printer)

        __repr__ = __str__

    _M_Demo.PrinterPrx = Ice.createTempClass()
    class PrinterPrx(Ice.ObjectPrx):

        def printString(self, s, _ctx=None):
            return _M_Demo.Printer._op_printString.invoke(self, ((s, ), _ctx))

        def checkedCast(proxy, facetOrCtx=None, _ctx=None):
            return _M_Demo.PrinterPrx.ice_checkedCast(proxy, '::Demo::Printer', facetOrCtx, _ctx)
        checkedCast = staticmethod(checkedCast)

        def uncheckedCast(proxy, facet=None):
            return _M_Demo.PrinterPrx.ice_uncheckedCast(proxy, facet)
        uncheckedCast = staticmethod(uncheckedCast)

    _M_Demo._t_PrinterPrx = IcePy.defineProxy('::Demo::Printer', PrinterPrx)

    _M_Demo._t_Printer = IcePy.defineClass('::Demo::Printer', Printer, (), True, None, (), ())
    Printer.ice_type = _M_Demo._t_Printer

    Printer._op_printString = IcePy.Operation('printString', Ice.OperationMode.Normal, Ice.OperationMode.Normal, False, (), (((), IcePy._t_string),), (), None, ())

    _M_Demo.Printer = Printer
    del Printer

    _M_Demo.PrinterPrx = PrinterPrx
    del PrinterPrx

# End of module Demo
