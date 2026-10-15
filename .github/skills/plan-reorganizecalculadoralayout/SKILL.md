---
name: plan-reorganizecalculadoralayout
description: plan-reorganizeCalculadoraLayout
disable-model-invocation: true
---
# Reorganizar layout da CalculadoraView

## Objetivo

Reorganizar o bloco `children` do método `build` em `calculadora_view.dart` para ter:

1. Um único grupo **"Dados a Preencher Manualmente"** com os campos na ordem:
   - Data de Nascimento
   - Sexo
   - Data de Admissão
   - Tempo de Outras Funções (anos)

2. Um único grupo **"Dados Calculados Automaticamente"** com os campos:
   - Idade Atual (anos)
   - Tempo na Função ACS/ACE (anos)
   - Tempo Total de Contribuição INSS/Regime Próprio (anos)

## Problema atual

O arquivo `lib/views/calculadora_view.dart` possui seções duplicadas e fora de ordem:

- **Duas** seções "Dados a Preencher Manualmente"
- **Duas** seções "Dados Calculados Automaticamente"
- Campos `_idadeCtrl` e `_tempoFuncaoCtrl` aparecem duas vezes no widget tree (conflito de controllers)
- Campo Sexo está entre Data de Nascimento e Data de Admissão em vez da posição 2 prevista
- Campos automáticos usam `readOnly: true` na primeira aparição e `enabled: false` na segunda

## Alterações necessárias

### Arquivo: `lib/views/calculadora_view.dart` — método `build`

Substituir todo o bloco entre o primeiro `const Divider()` e o `const SizedBox(height: 24)` (antes do botão `ElevatedButton`) pelo seguinte:

```dart
const Divider(),
const Text(
  'Dados a Preencher Manualmente:',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  ),
),
const SizedBox(height: 10),

// 1. Data de Nascimento
DatePickerFormField(
  controller: _dataNascimentoCtrl,
  labelText: 'Data de Nascimento',
  icon: Icons.calendar_today,
  onTap: () => _selecionarData(context, true),
  onClear: () => _limparData(true),
),
const SizedBox(height: 12),

// 2. Sexo
DropdownButtonFormField<String>(
  initialValue: _sexo,
  decoration: const InputDecoration(labelText: 'Sexo'),
  items: const [
    DropdownMenuItem(value: 'F', child: Text('Feminino')),
    DropdownMenuItem(value: 'M', child: Text('Masculino')),
  ],
  onChanged: (val) => setState(() => _sexo = val!),
),
const SizedBox(height: 12),

// 3. Data de Admissão
DatePickerFormField(
  controller: _dataAdmissaoCtrl,
  labelText: 'Data de Admissão',
  icon: Icons.calendar_today,
  onTap: () => _selecionarData(context, false),
  onClear: () => _limparData(false),
),
const SizedBox(height: 12),

// 4. Tempo de Outras Funções
TextFormField(
  controller: _tempoOutrasFuncoesCtrl,
  decoration: const InputDecoration(
    labelText: 'Tempo de Outras Funções (anos)',
    helperText:
        'Digite o tempo total de outras profissões antes de ser ACS/ACE.',
  ),
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, preencha este campo.';
    }
    if (int.tryParse(value) == null) {
      return 'Por favor, insira um número válido.';
    }
    return null;
  },
),
const SizedBox(height: 20),

const Divider(),
const Text(
  'Dados Calculados Automaticamente:',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  ),
),
const SizedBox(height: 10),

// 1. Idade Atual
TextField(
  controller: _idadeCtrl,
  decoration: const InputDecoration(
    labelText: 'Idade Atual (anos)',
    filled: true,
  ),
  enabled: false,
),
const SizedBox(height: 12),

// 2. Tempo na Função ACS/ACE
TextField(
  controller: _tempoFuncaoCtrl,
  decoration: const InputDecoration(
    labelText: 'Tempo na Função ACS/ACE (anos)',
    filled: true,
  ),
  enabled: false,
),
const SizedBox(height: 12),

// 3. Tempo de Contribuição Total
TextField(
  controller: _tempoContribCtrl,
  decoration: const InputDecoration(
    labelText:
        'Tempo Total de Contribuição INSS/Regime Próprio (anos)',
    filled: true,
  ),
  enabled: false,
),

const SizedBox(height: 24),
```

## Verificação pós-implementação

- [ ] Apenas uma seção "Dados a Preencher Manualmente"
- [ ] Apenas uma seção "Dados Calculados Automaticamente"
- [ ] Ordem dos campos manuais: Data de Nascimento → Sexo → Data de Admissão → Tempo de Outras Funções
- [ ] Campos automáticos usam `enabled: false` (sem duplicatas de controller no widget tree)
- [ ] App compila sem erros
- [ ] Selecionar Data de Nascimento preenche Idade automaticamente
- [ ] Selecionar Data de Admissão preenche Tempo na Função automaticamente
- [ ] Tempo Total de Contribuição é calculado corretamente
