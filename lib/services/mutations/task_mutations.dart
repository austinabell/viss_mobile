String createTask = """
  mutation (\$name: String, \$address: String!, \$city: String!, \$province: String!, 
  \$lat: Float, \$lng: Float, \$isAllDay: Boolean, \$windowStart: String, 
  \$windowEnd: String, \$duration: Int!, \$notes: String, 
  \$email: String, \$phone: String) {
    createTask(name: \$name, address: \$address, city: \$city, province: \$province, 
    lat: \$lat, lng: \$lng, isAllDay: \$isAllDay, windowStart: \$windowStart, 
    windowEnd: \$windowEnd, duration: \$duration, notes: \$notes, 
    email: \$email, phone: \$phone) {
      id
      name
      order
      address
      city
      province
      lat
      lng
      isAllDay
      windowStart
      windowEnd
      duration
      notes
      email
      phone
      status
    }
  }
"""
    .replaceAll('\n', ' ');

String updateTaskStatus = """
  mutation(\$id: ID!, \$status: String, \$notes: String) {
    updateTask (id: \$id, status: \$status, notes: \$notes) {
      id
      name
      order
      address
      city
      province
      lat
      lng
      isAllDay
      windowStart
      windowEnd
      duration
      notes
      email
      phone
      status
    }
  }
"""
    .replaceAll('\n', ' ');

String updateTaskOrder = """
  mutation (\$ids: [ID!]!) {
    updateTaskOrder (ids: \$ids)
  }
"""
    .replaceAll('\n', ' ');
