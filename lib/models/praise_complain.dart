class PraiseComplaint {
  final String messageType;
  final String phone;
  final String text;
  final String emotion;
  final String uploadedFilePath;

  PraiseComplaint(this.messageType, this.uploadedFilePath, this.emotion,
      this.phone, this.text);

  Map<String, dynamic> get map => {
        'messageType': messageType,
        'fileUrl': uploadedFilePath,
        'customer': {'fullName': phone, 'phoneNumber': phone},
        'emotion': emotion,
        'text': text
      };
}
