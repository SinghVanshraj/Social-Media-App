import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {

  static final auth = Supabase.instance.client.auth;
  static final database = Supabase.instance.client;
  static final bucket = Supabase.instance.client.storage;
}