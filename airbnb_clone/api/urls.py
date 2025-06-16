from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    UserViewSet, PropertyViewSet, BookingViewSet,
    ReviewViewSet, PaymentViewSet
)

router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'properties', PropertyViewSet)
router.register(r'bookings', BookingViewSet, basename='booking')
router.register(r'reviews', ReviewViewSet)
router.register(r'payments', PaymentViewSet, basename='payment')

urlpatterns = [
    path('', include(router.urls)),
    path('auth/', include('rest_framework.urls')),
]
