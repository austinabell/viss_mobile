String login = """
  mutation(\$email: String!, \$password: String!) {
    login(email: \$email, password: \$password) {
      id
      email
      name
      username
      isStarted
    }
  }
"""
    .replaceAll('\n', ' ');
