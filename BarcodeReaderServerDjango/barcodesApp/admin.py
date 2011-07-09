from barcodesApp.models import Barcode
from django.contrib import admin

class BarcodeAdmin(admin.ModelAdmin):
    list_display = ('bc', 'price', 'image_src')

admin.site.register(Barcode, BarcodeAdmin)
