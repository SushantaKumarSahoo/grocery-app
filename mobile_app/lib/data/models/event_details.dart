class EventDetails {
  String occasion;
  DateTime? eventDate;
  int expectedGuests;
  String deliveryAddress;
  String preferredDeliveryTime;
  double? budget;
  String additionalNotes;

  EventDetails({
    this.occasion = '',
    this.eventDate,
    this.expectedGuests = 0,
    this.deliveryAddress = '',
    this.preferredDeliveryTime = '',
    this.budget,
    this.additionalNotes = '',
  });
}
