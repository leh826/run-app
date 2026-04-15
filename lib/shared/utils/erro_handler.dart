class ErrorHandler {
  static String getMessage(dynamic error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('invalid login credentials')) {
      return "Email ou senha inválidos";
    }

    if (msg.contains('user already registered')) {
      return "Esse email já está cadastrado";
    }

    if (msg.contains('network')) {
      return "Sem internet";
    }

    if (msg.contains('unauthorized')) {
      return "Sem permissão";
    }

    if (msg.contains('password')) {
      return "A senha deve ter pelo menos 6 caracteres";
    }
    return msg;
  }
}