from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Property, Booking, Review, Payment

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name')
        read_only_fields = ('id',)

class PropertySerializer(serializers.ModelSerializer):
    owner = UserSerializer(read_only=True)
    average_rating = serializers.SerializerMethodField()

    class Meta:
        model = Property
        fields = ('id', 'owner', 'title', 'description', 'price_per_night',
                 'location', 'bedrooms', 'bathrooms', 'max_guests',
                 'created_at', 'updated_at', 'average_rating')
        read_only_fields = ('id', 'created_at', 'updated_at')

    def get_average_rating(self, obj):
        reviews = obj.reviews.all()
        if reviews:
            return sum(review.rating for review in reviews) / len(reviews)
        return None

class BookingSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    property = PropertySerializer(read_only=True)
    property_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = Booking
        fields = ('id', 'user', 'property', 'property_id', 'check_in_date',
                 'check_out_date', 'guests_count', 'total_price', 'status',
                 'created_at', 'updated_at')
        read_only_fields = ('id', 'total_price', 'status', 'created_at', 'updated_at')

    def validate(self, data):
        # Check if the property is available for the given dates
        if Booking.objects.filter(
            property_id=data['property_id'],
            status='confirmed',
            check_in_date__lte=data['check_out_date'],
            check_out_date__gte=data['check_in_date']
        ).exists():
            raise serializers.ValidationError("Property is not available for these dates")
        
        # Check if check_out_date is after check_in_date
        if data['check_in_date'] >= data['check_out_date']:
            raise serializers.ValidationError("Check-out date must be after check-in date")

        return data

    def create(self, validated_data):
        property_id = validated_data.pop('property_id')
        property_obj = Property.objects.get(id=property_id)
        
        # Calculate total price
        days = (validated_data['check_out_date'] - validated_data['check_in_date']).days
        total_price = property_obj.price_per_night * days
        
        booking = Booking.objects.create(
            property=property_obj,
            total_price=total_price,
            **validated_data
        )
        return booking

class ReviewSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    property = PropertySerializer(read_only=True)
    property_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = Review
        fields = ('id', 'user', 'property', 'property_id', 'rating', 'comment',
                 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

    def validate(self, data):
        # Ensure user has a confirmed booking for this property
        if not Booking.objects.filter(
            user=self.context['request'].user,
            property_id=data['property_id'],
            status='completed'
        ).exists():
            raise serializers.ValidationError(
                "You can only review properties where you have completed a stay"
            )
        return data

class PaymentSerializer(serializers.ModelSerializer):
    booking = BookingSerializer(read_only=True)
    booking_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = Payment
        fields = ('id', 'booking', 'booking_id', 'amount', 'status',
                 'payment_method', 'transaction_id', 'created_at', 'updated_at')
        read_only_fields = ('id', 'status', 'created_at', 'updated_at')

    def validate(self, data):
        # Ensure booking exists and is pending payment
        try:
            booking = Booking.objects.get(id=data['booking_id'])
            if booking.status != 'pending':
                raise serializers.ValidationError("This booking is not pending payment")
            if Payment.objects.filter(booking=booking).exists():
                raise serializers.ValidationError("Payment already exists for this booking")
        except Booking.DoesNotExist:
            raise serializers.ValidationError("Invalid booking ID")
        return data
