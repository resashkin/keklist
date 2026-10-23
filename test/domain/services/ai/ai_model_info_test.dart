import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/ai/ai_model_info.dart';

void main() {
  test('reads the parameter count from a name', () {
    expect(AiModelInfo.parameterBillions('Qwen/Qwen2.5-0.5B-Instruct-GGUF'), 0.5);
    expect(AiModelInfo.parameterBillions('HuggingFaceTB/SmolLM2-360M-Instruct'), closeTo(0.36, 1e-9));
    expect(AiModelInfo.parameterBillions('unsloth/gemma-4-12b-it-GGUF'), 12);
    expect(AiModelInfo.parameterBillions('Qwen2.5'), isNull);
  });

  test('models under a billion parameters are weak', () {
    expect(AiModelInfo.isWeakName('qwen2.5-0.5b-instruct-q4_k_m.gguf'), isTrue);
    expect(AiModelInfo.isWeakName('Qwen2.5-1.5B-Instruct'), isFalse);
    expect(AiModelInfo.isWeakName('Gemma-4-E2B-it'), isFalse);
    expect(AiModelInfo.isWeakName('some-model'), isFalse);
  });
}
