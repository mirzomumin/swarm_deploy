from django.http import JsonResponse


def healthcheck(request):
    # Check system
    return JsonResponse({'msg': 'success'})
