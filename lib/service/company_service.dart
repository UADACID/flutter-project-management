import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';

class CompanyService {
  Dio client = Client.init();

  Future<Response> getCompanies() async {
    return client.get('/api/v1/companies');
    // return client.get('https://mock.codes/408');
  }

  Future<Response> createCompanies(dynamic payload) async {
    return client.post('/api/v1/companies', data: payload);
    // return client.post('https://mock.codes/500');
  }

  Future<Response> createTeam(dynamic payload) async {
    return client.post('/api/v1/teams', data: payload);
    // return client.post('https://mock.codes/500');
  }

  Future<Response> inviteMember(String companyId, dynamic payload) async {
    return client.post('/api/v1/invites/companies/$companyId', data: payload);
    // return client.post('https://mock.codes/500');
  }

  Future<Response> checkSubscription(String companyId) async {
    return client.get('/api/v1/companies/$companyId/check-subscription');
    // return client.get('https://mock.codes/408');
  }

  Future<Response> checkInvitationToken(String invitationToken) async {
    return client.get('/api/v1/invites/$invitationToken');
    // return client.get('https://mock.codes/408');
  }
}
