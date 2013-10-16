from django.contrib import admin
from admintimestamps import TimestampedAdminMixin
from .models import Project
from .forms import ProjectForm


class ProjectAdmin(TimestampedAdminMixin, admin.ModelAdmin):
    list_display = ('domain', 'path', 'status',)
    list_filter = ('status',)
    search_fields = ('domain',)
    ordering = ('domain',)
    form = ProjectForm

admin.site.register(Project, ProjectAdmin)