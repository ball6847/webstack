from django.http import HttpResponse

def index(request):
    body = "Hello World"
    return HttpResponse(body)

