module Smith
  module Client
    ClientHealthCheckSteps = RSpec::EM.async_steps do

      def assert_periodic_health_checks_made_when_running(&callback)
        # Verify that 2 health check requests are made
        d1 = add_http_request_expectation status_endpoint do |request_params|
          test_printer_status.delete(SPARK_STATE_PS_KEY)
          test_printer_status.delete(SPARK_JOB_STATE_PS_KEY)
          test_printer_status.delete(LOCAL_JOB_UUID_PS_KEY)
          expect(request_params[:data].to_json).to eq(test_printer_status.to_json)
        end
        
        d2 = add_http_request_expectation status_endpoint do |request_params|
          test_printer_status.delete(SPARK_STATE_PS_KEY)
          test_printer_status.delete(SPARK_JOB_STATE_PS_KEY)
          test_printer_status.delete(LOCAL_JOB_UUID_PS_KEY)
          expect(request_params[:data].to_json).to eq(test_printer_status.to_json)
        end

        when_succeed(d1, d2) { callback.call }

        start_client
      end

      def assert_error_logged_and_health_checks_resume_after_temporary_connection_loss(&callback)

        good_status_endpoint = status_endpoint
       
        # Wait for a health check to complete successfully 
        add_log_subscription(LogMessages::POST_REQUEST_SUCCESS,
                             good_status_endpoint, test_status_payload.to_json) do |subscription|

          subscription.cancel

          # After getting the first health check, change the server url to simulate unreachable server
          Settings.server_url = 'http://bad.url'
          bad_status_endpoint = status_endpoint

          # Next health check request attempts fail
          # Cancel the log subscription as soon as a matching entry is found so that two failed health check requests
          # are guaranteed to have been made
          d1 = add_log_subscription(LogMessages::POST_REQUEST_URL_UNREACHABLE,
                               bad_status_endpoint, test_status_payload.to_json) { |s| s.cancel }

          d2 = add_log_subscription(LogMessages::POST_REQUEST_URL_UNREACHABLE,
                               bad_status_endpoint, test_status_payload.to_json) { |s| s.cancel }

          # Two failed health check requests have been made
          when_succeed(d1, d2) do
       
            # Wait for health checks to start succeeding 
            d3 = add_http_request_expectation good_status_endpoint

            # Wait for log entry indicating that health checks are succeeding
            d4 = add_log_subscription(LogMessages::HTTP_REQUEST_LOGGING_RESUMPTION)
           
            when_succeed(d3, d4) do
              # Check that non-debug post request error message is logged only when request fails for the first time
              # If logging suspension was not working in the HTTPClient, then there would be two error messages since
              # the above subscriptions to POST_REQUEST_URL_UNREACHABLE ensure that two failed requests were made
              expect(grep_log(LogMessages::HTTP_REQUEST_LOGGING_SUSPENSION, bad_status_endpoint).length).to eq(1)
              callback.call
            end

            # Reset the server url to simulate server becoming reachable again
            Settings.server_url = dummy_server.url

          end
        end

        start_client
      end

    end
  end
end
