# -*- coding: utf-8 -*-
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Deleting model 'ProjectModel'
        db.delete_table(u'webstack_projectmodel')

        # Adding model 'Project'
        db.create_table(u'webstack_project', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('domain', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('path', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('status', self.gf('django.db.models.fields.BooleanField')(default=True)),
        ))
        db.send_create_signal(u'webstack', ['Project'])


    def backwards(self, orm):
        # Adding model 'ProjectModel'
        db.create_table(u'webstack_projectmodel', (
            ('status', self.gf('django.db.models.fields.BooleanField')(default=True)),
            ('path', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('domain', self.gf('django.db.models.fields.CharField')(max_length=100)),
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
        ))
        db.send_create_signal(u'webstack', ['ProjectModel'])

        # Deleting model 'Project'
        db.delete_table(u'webstack_project')


    models = {
        u'webstack.project': {
            'Meta': {'object_name': 'Project'},
            'domain': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'path': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'status': ('django.db.models.fields.BooleanField', [], {'default': 'True'})
        }
    }

    complete_apps = ['webstack']