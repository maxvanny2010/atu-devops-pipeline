package ie.atu.devops.taskmanager;

import org.junit.jupiter.api.Test;
import org.springframework.boot.micrometer.metrics.test.autoconfigure.AutoConfigureMetrics;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMetrics
class MonitoringIntegrationTest {

    @LocalServerPort
    int port;

    private final HttpClient client = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    @Test
    void healthEndpointIsUp() throws Exception {
        assertHealthy("/actuator/health");
    }

    @Test
    void livenessEndpointIsUp() throws Exception {
        assertHealthy("/actuator/health/liveness");
    }

    @Test
    void readinessEndpointIsUp() throws Exception {
        assertHealthy("/actuator/health/readiness");
    }

    @Test
    void prometheusEndpointExposesMetrics() throws Exception {
        assertEquals(200, get("/actuator/health").statusCode());

        HttpResponse<String> response = get("/actuator/prometheus");
        assertEquals(200, response.statusCode());

        String metrics = response.body();

        for (String metric : new String[]{
                "jvm_memory_used_bytes",
                "jvm_threads_live_threads",
                "process_cpu_usage",
                "system_cpu_usage",
                "http_server_requests_seconds_count",
                "hikaricp_connections",
                "logback_events_total"
        }) {
            assertTrue(metrics.lines().anyMatch(line ->
                    line.startsWith(metric + "{") ||
                    line.startsWith(metric + " ")),
                    "Missing metric: " + metric);
        }

        assertTrue(metrics.contains("application=\"task-manager\""));
    }

    private void assertHealthy(String path) throws Exception {
        HttpResponse<String> response = get(path);

        assertEquals(200, response.statusCode());
        assertTrue(response.body().matches(
                "(?s).*\"status\"\\s*:\\s*\"UP\".*"));
    }

    private HttpResponse<String> get(String path) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://127.0.0.1:" + port + path))
                .timeout(Duration.ofSeconds(15))
                .GET()
                .build();

        return client.send(request, HttpResponse.BodyHandlers.ofString());
    }
}
