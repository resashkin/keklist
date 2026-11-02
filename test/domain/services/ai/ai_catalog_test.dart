import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:keklist/domain/services/ai/ai_catalog.dart';
import 'package:keklist/domain/services/ai/ai_model_info.dart';

void main() {
  http.Response json(Object body) => http.Response(jsonEncode(body), 200);

  test('puts the recommended model first, then open chat models from the newest lists, smallest first', () async {
    final List<String> fetched = [];
    final AiCatalog catalog = AiCatalog(
      client: MockClient((request) async {
        final String url = request.url.toString();
        fetched.add(url);
        if (url.contains('api.github.com')) {
          return json([
            {'name': '1_0_9.json'},
            {'name': '1_0_20.json'},
            {'name': 'ios_1_0_0.json'},
            {'name': 'README.md'},
          ]);
        }
        if (url.endsWith('1_0_20.json') || url.endsWith('ios_1_0_0.json')) {
          return json({
            'models': [
              {
                'name': 'Big',
                'modelId': 'org/big',
                'modelFile': 'big.litertlm',
                'sizeInBytes': 3000,
                'commitHash': 'abc',
                'taskTypes': ['llm_chat'],
              },
              {
                'name': 'Small',
                'modelId': 'org/small',
                'modelFile': 'small.litertlm',
                'sizeInBytes': 1000,
                'commitHash': 'def',
                'taskTypes': ['llm_chat'],
              },
              {
                'name': 'DeepSeek-R1-Distill-Qwen-1.5B',
                'modelId': 'org/r1',
                'modelFile': 'r1.litertlm',
                'sizeInBytes': 500,
                'taskTypes': ['llm_chat'],
              },
              {
                'name': 'Gated',
                'modelId': 'org/gated',
                'modelFile': 'g.litertlm',
                'sizeInBytes': 10,
                'taskTypes': ['llm_chat'],
              },
              {
                'name': 'Segmenter',
                'modelId': 'org/seg',
                'modelFile': 'seg.task',
                'sizeInBytes': 5,
                'taskTypes': ['mp_scrapbook'],
              },
            ],
          });
        }
        if (url.contains('/api/models/org/gated')) return json({'gated': 'manual'});
        if (url.contains('${AiCatalog.recommendedRepo}/tree/')) {
          return json([
            {'path': 'gemma-4-E2B-it-Q3_K_M.gguf', 'size': 900},
            {'path': 'gemma-4-E2B-it-Q4_K_M.gguf', 'size': 1100},
          ]);
        }
        if (url.contains('/api/models/')) return json({'gated': false});
        return http.Response('not found', 404);
      }),
    );
    final List<AiModelInfo> models = await catalog.galleryModels();
    expect(models.map((model) => model.name), ['gemma-4-E2B-it-Q4_K_M', 'Small', 'Big']);
    expect(models[1].url.toString(), 'https://huggingface.co/org/small/resolve/def/small.litertlm?download=true');
    expect(fetched.where((url) => url.endsWith('1_0_9.json')), isEmpty);
  });

  test('lists GGUF files without projectors, pinned to the revision', () async {
    final AiCatalog catalog = AiCatalog(
      client: MockClient((request) async {
        if (request.url.path == '/api/models/org/repo') return json({'gated': false, 'sha': 'rev1'});
        return json([
          {
            'path': 'model-q8.gguf',
            'size': 2000,
            'lfs': {'size': 2000},
          },
          {
            'path': 'model-q4.gguf',
            'size': 1000,
            'lfs': {'size': 1000},
          },
          {'path': 'mmproj-f16.gguf', 'size': 500},
          {'path': 'README.md', 'size': 10},
        ]);
      }),
    );
    final List<AiModelInfo> files = await catalog.ggufFiles('org/repo');
    expect(files.map((file) => file.file), ['model-q4.gguf', 'model-q8.gguf']);
    expect(files.first.revision, 'rev1');
    expect(files.first.format, AiModelFormat.gguf);
  });

  test('tells reasoning distills from chat models', () {
    expect(AiCatalog.isReasoning('DeepSeek-R1-Distill-Qwen-1.5B'), isTrue);
    expect(AiCatalog.isReasoning('Qwen2.5-1.5B-Instruct'), isFalse);
    expect(AiCatalog.isReasoning('gemma-4-E2B-it-Q4_K_M'), isFalse);
  });
}
