from django.contrib import admin
from admintimestamps import TimestampedAdminMixin
from .models import Project



class ProjectAdmin(TimestampedAdminMixin, admin.ModelAdmin):
    list_display = ('domain', 'status',)
    list_filter = ('status',)
    search_fields = ('domain',)
    ordering = ('id',)

admin.site.register(Project, ProjectAdmin)