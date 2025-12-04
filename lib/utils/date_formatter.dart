
class DateFormatter {
  static String formatToIndonesian(String dateString) {
    try {
      // Parse tanggal dari format yang diterima (biasanya YYYY-MM-DD)
      DateTime date = DateTime.parse(dateString);
      
      // Daftar nama bulan dalam bahasa Indonesia
      List<String> months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      
      // Format ke bahasa Indonesia: DD Bulan YYYY
      String day = date.day.toString();
      String month = months[date.month - 1];
      String year = date.year.toString();
      
      return '$day $month $year';
    } catch (e) {
      // Jika parsing gagal, kembalikan string asli
      return dateString;
    }
  }
  
  static String formatToIndonesianShort(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      
      // Daftar nama bulan pendek dalam bahasa Indonesia
      List<String> monthsShort = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      
      String day = date.day.toString();
      String month = monthsShort[date.month - 1];
      String year = date.year.toString();
      
      return '$day $month $year';
    } catch (e) {
      return dateString;
    }
  }
  
  static String formatWithTime(String dateString, String timeString) {
    try {
      String formattedDate = formatToIndonesian(dateString);
      return '$formattedDate, $timeString';
    } catch (e) {
      return '$dateString $timeString';
    }
  }
}
