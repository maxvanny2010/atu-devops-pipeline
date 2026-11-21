package ie.atu.devops.taskmanager;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.slf4j.LoggerFactory;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ExtendWith(OutputCaptureExtension.class)
class StructuredLoggingTest {

    @Test
    void shouldProduceStructuredEcsLog(CapturedOutput output) {
        String message = "structured-logging-verification";

        LoggerFactory.getLogger(StructuredLoggingTest.class)
                .info(message);

        String line = output.getOut().lines()
                .filter(value -> value.startsWith("{"))
                .filter(value -> value.contains(message))
                .findFirst()
                .orElseThrow();

        JsonNode json = new ObjectMapper().readTree(line);

        assertThat(json.path("@timestamp").asText()).isNotBlank();
        assertThat(json.path("log").path("level").asText())
                .isEqualTo("INFO");
        assertThat(json.path("service").path("name").asText())
                .isEqualTo("task-manager");
        assertThat(json.path("message").asText())
                .isEqualTo(message);
        assertThat(json.path("ecs").path("version").asText())
                .isNotBlank();
    }
}
