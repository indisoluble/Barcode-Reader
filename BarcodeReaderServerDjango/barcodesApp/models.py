from django.db import models

class Barcode(models.Model):
    bc = models.CharField(max_length=20)
    price = models.IntegerField()
    
    def __unicode__(self):
        return self.bc
