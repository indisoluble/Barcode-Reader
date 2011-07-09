from django.db import models

class Barcode(models.Model):
    bc = models.CharField(max_length=20)
    desc = models.CharField(max_length=128)
    price = models.IntegerField()
    image = models.ImageField(upload_to='images')
    
    def __unicode__(self):
        return self.bc

    def image_src(self):
        return '<img src="%s"/>' % self.image.url
    image_src.allow_tags = True
