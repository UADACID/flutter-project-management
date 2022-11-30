import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';

class ScheduleService {
  Dio client = Client.init();

  String dynamicCompanyId = '';

  Future<Response> _getCompanyId(String moduleName, String moduleId) async {
    try {
      Response response = await client.get('/v2/$moduleName/$moduleId/company');
      if (response.data['companyId'] != null) {
        dynamicCompanyId = response.data['companyId'];

        client.options.queryParameters
            .addAll({'companyId': response.data['companyId']});
      }
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getEvents(String scheduleId, dynamic params) async {
    try {
      await _getCompanyId('schedules', scheduleId);
      Response response = await client.get(
          '/api/v1/schedules/$scheduleId/occurrences',
          queryParameters: params);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getEvent(String eventId) async {
    try {
      await _getCompanyId('events', eventId);
      Response response = await client.get('/v2/events/$eventId');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getEventOccurence(String eventId, String occurenceId) async {
    try {
      await _getCompanyId('events', eventId);
      Response response =
          await client.get('/v2/events/$eventId/occurrences/$occurenceId');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> toggleMembers(String eventId, dynamic body) async {
    return client.post('/v2/events/$eventId/members', data: body);
  }

  Future<Response> archiveEvent(String eventId) async {
    return client.patch('/api/v1/events/$eventId/archived');
  }

  Future<Response> createEvent(String scheduleId, dynamic body) async {
    try {
      await _getCompanyId('schedules', scheduleId);
      Response response =
          await client.post('/api/v1/schedules/$scheduleId/events', data: body);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> createEventOccurrence(
      String scheduleId, dynamic body) async {
    try {
      await _getCompanyId('schedules', scheduleId);
      Response response = await client
          .post('/api/v1/schedules/$scheduleId/occurrences', data: body);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> updateEvent(String eventId, dynamic body) async {
    return client.patch('/api/v1/events/$eventId', data: body);
  }

  Future<Response> updateSingleEventToOccurrence(
      String eventId, dynamic body) async {
    return client.patch(
        '/api/v1/events/$eventId/occurrences/single-to-recurring',
        data: body);
  }

  Future<Response> updateSingleEventOccurrence(
      String eventId, String occurrenceId, dynamic body) async {
    return client.patch('/api/v1/events/$eventId/occurrences/$occurrenceId',
        data: body);
  }

  Future<Response> updateAllEventOccurrence(
      String eventId, dynamic body) async {
    return client.patch('/api/v1/events/$eventId/occurrences', data: body);
  }

  Future<Response> toggleMembersOccurrence(String eventId, dynamic body) async {
    return client.post('/v2/events/$eventId/occurrences/members', data: body);
  }

  Future<Response> publicCalendar(String scheduleId, dynamic body) async {
    return client.post('/api/v1/schedules/$scheduleId/public-calendar',
        data: body);
  }
}
