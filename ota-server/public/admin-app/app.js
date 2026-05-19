const API_BASE = '/api';
const MAX_BROWSER_UPLOAD_BYTES = 8 * 1024 * 1024;

const state = {
  accessToken: localStorage.getItem('ota_admin_access_token') || '',
  refreshToken: localStorage.getItem('ota_admin_refresh_token') || '',
  admin: null,
  summary: null,
  devices: [],
  models: [],
  groups: [],
  tags: [],
  releases: [],
  campaigns: [],
  auditLogs: [],
  campaignDevices: [],
  selectedCampaignId: null,
  editingCampaignId: null,
  campaignRuleDrafts: [],
  deviceSearch: '',
  releaseFilterModelId: '',
  showArchivedCampaigns: false,
  releaseSubmitting: false,
};

const CAMPAIGN_RULE_TYPES = [
  { value: 'group', label: 'مجموعة', operatorLocked: true, operator: 'eq', valueMode: 'group' },
  { value: 'tag', label: 'وسم', operatorLocked: true, operator: 'eq', valueMode: 'tag' },
  { value: 'current_version', label: 'الإصدار الحالي', valueMode: 'string' },
  { value: 'model', label: 'الطراز', valueMode: 'string' },
  { value: 'board', label: 'اللوحة', valueMode: 'string' },
  { value: 'mac', label: 'MAC', valueMode: 'string' },
  { value: 'token', label: 'الرمز', valueMode: 'string' },
];

const CAMPAIGN_OPERATORS = [
  { value: 'eq', label: 'يساوي' },
  { value: 'neq', label: 'لا يساوي' },
  { value: 'contains', label: 'يحتوي على' },
  { value: 'prefix', label: 'يبدأ بـ' },
  { value: 'in', label: 'ضمن قائمة' },
];

const MESSAGE_TRANSLATIONS = {
  'invalid email or password': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
  'invalid refresh token': 'رمز تحديث الجلسة غير صالح.',
  'invalid access token': 'رمز الوصول غير صالح.',
  'missing bearer token': 'رمز Bearer مفقود.',
  'invalid bearer token': 'رمز Bearer غير صالح.',
  'admin role required': 'صلاحية المشرف مطلوبة.',
  'campaign not found': 'الحملة غير موجودة.',
  'unknown release_id': 'release_id غير معروف.',
  'archived campaigns cannot be edited': 'لا يمكن تعديل الحملات المؤرشفة.',
  'archived campaigns cannot be activated': 'لا يمكن تفعيل الحملات المؤرشفة.',
  'unknown firmware_model_id': 'firmware_model_id غير معروف.',
  'model is required when firmware_model_id is not provided': 'اختر نموذج البرنامج الثابت أو أدخل مفتاح طراز بديل.',
  'model does not match firmware_model_id': 'مفتاح الطراز لا يطابق النموذج المختار.',
  'Upload firmware file or provide artifact path.': 'ارفع ملف البرنامج الثابت أو أدخل مسار الملف.',
  'Large browser uploads can timeout. Provide a /firmware/ path for this file.': 'هذا الملف كبير وقد يفشل رفعه عبر المتصفح. ضع الملف داخل /firmware/ ثم أدخل مساره.',
  'artifact_path must start with /firmware/': 'مسار الملف يجب أن يبدأ بـ /firmware/.',
  'artifact_path resolves outside public/firmware': 'مسار الملف غير مسموح. استخدم ملفًا داخل /firmware/.',
  'artifact_path file not found': 'الملف المحدد في المسار غير موجود داخل /firmware/.',
  'artifact_path or artifact_url is required': 'أدخل مسار ملف داخل /firmware/ أو رابط تحميل خارجي أو ارفع ملفًا من المتصفح.',
  'artifact_url must be a valid URL': 'رابط التحميل الخارجي غير صالح.',
  'artifact_url must use http or https': 'رابط التحميل يجب أن يبدأ بـ http أو https.',
  'artifact_url downloaded an empty file': 'رابط التحميل أعاد ملفًا فارغًا.',
  'release not found': 'الإصدار غير موجود.',
  'release has campaigns; pause it instead of deleting': 'لا يمكن حذف إصدار مرتبط بحملات. أوقفه بدل الحذف أو احذف الحملات المرتبطة أولاً.',
  'artifact file is required': 'ملف البرنامج الثابت مطلوب للرفع.',
  'Internal server error': 'تعذر إنشاء الإصدار. تحقق من مسار الملف وأنه موجود داخل /firmware/.',
  'Payload too large': 'حجم ملف الرفع كبير جدًا لبوابة الخادم.',
  'No refresh token available': 'لا يوجد رمز تحديث متاح.',
  'Session expired': 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.',
  'Failed to fetch': 'تعذر الاتصال بالخادم. تحقق من الشبكة ثم حاول مرة أخرى.',
  'NetworkError when attempting to fetch resource.': 'تعذر الاتصال بالخادم. تحقق من الشبكة ثم حاول مرة أخرى.',
};

const DEVICE_STATUS_LABELS = {
  registered: 'مسجل',
  checking: 'جارٍ التحقق',
  idle: 'خامل',
  available: 'متاح',
  downloading: 'جارٍ التنزيل',
  downloaded: 'تم التنزيل',
  applying: 'جارٍ التطبيق',
  rebooting: 'جارٍ إعادة التشغيل',
  updated: 'تم التحديث',
  error: 'خطأ',
};

const ELIGIBILITY_STATUS_LABELS = {
  pending: 'قيد الانتظار',
  matched: 'مطابق',
  already_current: 'محدّث بالفعل',
  filtered: 'مستبعد بالقواعد',
  rollout_hold: 'معلّق بسبب نسبة الإطلاق',
};

const UPDATE_STATUS_LABELS = {
  pending: 'قيد الانتظار',
  available: 'متاح',
  downloading: 'جارٍ التنزيل',
  downloaded: 'تم التنزيل',
  applying: 'جارٍ التطبيق',
  rebooting: 'جارٍ إعادة التشغيل',
  idle: 'خامل',
  updated: 'تم التحديث',
  delivered: 'تم التسليم',
  error: 'خطأ',
};

function translateKnownMessage(message) {
  const normalized = String(message ?? '').trim();
  if (/Cannot PATCH \/api\/admin\/devices\/\d+\/hotspot-license/.test(normalized) || /\/api\/admin\/devices\/\d+\/hotspot-license/.test(normalized)) {
    return 'واجهة الترخيص منشورة لكن مسار الترخيص غير موجود في خادم الإنتاج. أعد نشر Backend الإنتاج قبل استخدام هذا الزر.';
  }
  return MESSAGE_TRANSLATIONS[normalized] ?? normalized;
}

function tokenTail(token) {
  const value = String(token ?? '').trim();
  if (!value) {
    return '-';
  }
  return value.length > 13 ? value.slice(-13) : value;
}

function translateValue(value, dictionary) {
  const normalized = String(value ?? '').trim();
  if (!normalized) {
    return '-';
  }

  return dictionary[normalized] ?? normalized;
}

const elements = {
  loginPanel: document.getElementById('loginPanel'),
  appPanel: document.getElementById('appPanel'),
  loginForm: document.getElementById('loginForm'),
  loginMessage: document.getElementById('loginMessage'),
  globalMessage: document.getElementById('globalMessage'),
  refreshButton: document.getElementById('refreshButton'),
  logoutButton: document.getElementById('logoutButton'),
  sessionBadge: document.getElementById('sessionBadge'),
  summaryGrid: document.getElementById('summaryGrid'),
  devicesTable: document.getElementById('devicesTable'),
  modelsTable: document.getElementById('modelsTable'),
  groupsTable: document.getElementById('groupsTable'),
  tagsTable: document.getElementById('tagsTable'),
  releasesTable: document.getElementById('releasesTable'),
  releaseMessage: document.getElementById('releaseMessage'),
  campaignsTable: document.getElementById('campaignsTable'),
  releaseModelSelect: document.getElementById('releaseModelSelect'),
  releaseFilterSelect: document.getElementById('releaseFilterSelect'),
  campaignReleaseSelect: document.getElementById('campaignReleaseSelect'),
  assignGroupSelect: document.getElementById('assignGroupSelect'),
  assignTagSelect: document.getElementById('assignTagSelect'),
  deviceSearchInput: document.getElementById('deviceSearchInput'),
  showArchivedCampaignsInput: document.getElementById('showArchivedCampaignsInput'),
  addCampaignRuleButton: document.getElementById('addCampaignRuleButton'),
  cancelCampaignEditButton: document.getElementById('cancelCampaignEditButton'),
  campaignFormTitle: document.getElementById('campaignFormTitle'),
  campaignSubmitButton: document.getElementById('campaignSubmitButton'),
  campaignRuleList: document.getElementById('campaignRuleList'),
  campaignRulesPreview: document.getElementById('campaignRulesPreview'),
  campaignDetailsPanel: document.getElementById('campaignDetailsPanel'),
  campaignDetailsTitle: document.getElementById('campaignDetailsTitle'),
  campaignDetailsMeta: document.getElementById('campaignDetailsMeta'),
  campaignDevicesTable: document.getElementById('campaignDevicesTable'),
  auditLogsTable: document.getElementById('auditLogsTable'),
};

const forms = {
  model: document.getElementById('modelForm'),
  group: document.getElementById('groupForm'),
  tag: document.getElementById('tagForm'),
  release: document.getElementById('releaseForm'),
  campaign: document.getElementById('campaignForm'),
  assignGroup: document.getElementById('assignGroupForm'),
  assignTag: document.getElementById('assignTagForm'),
};

function setMessage(message, kind = 'muted', target = elements.globalMessage) {
  target.textContent = message;
  target.className = `inline-message ${kind}`;
}

function escapeHtml(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function optionMarkup(items, selectedValue) {
  return items.map((item) => `
    <option value="${escapeHtml(item.value)}"${String(item.value) === String(selectedValue ?? '') ? ' selected' : ''}>${escapeHtml(item.label)}</option>
  `).join('');
}

function formatDate(value) {
  if (!value) {
    return '-';
  }

  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? '-' : date.toLocaleString('ar-SA');
}

function formatBytes(value) {
  const bytes = Number(value || 0);
  if (!Number.isFinite(bytes) || bytes <= 0) {
    return '-';
  }

  if (bytes >= 1024 * 1024 * 1024) {
    return `${(bytes / (1024 * 1024 * 1024)).toFixed(2)} GB`;
  }

  if (bytes >= 1024 * 1024) {
    return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
  }

  if (bytes >= 1024) {
    return `${(bytes / 1024).toFixed(1)} KB`;
  }

  return `${bytes} B`;
}

function releasePrimaryFile(release) {
  return Array.isArray(release.files) && release.files.length ? release.files[0] : null;
}

function fileNameFromUrl(value) {
  try {
    const parsed = new URL(String(value || ''), window.location.origin);
    const name = parsed.pathname.split('/').filter(Boolean).pop();
    return name ? decodeURIComponent(name) : '-';
  } catch {
    const parts = String(value || '').split('/').filter(Boolean);
    return parts.pop() || '-';
  }
}

async function copyText(value) {
  const text = String(value || '');
  if (!text) {
    return false;
  }

  if (navigator.clipboard && window.isSecureContext) {
    await navigator.clipboard.writeText(text);
    return true;
  }

  const input = document.createElement('textarea');
  input.value = text;
  input.style.position = 'fixed';
  input.style.opacity = '0';
  document.body.appendChild(input);
  input.select();
  const ok = document.execCommand('copy');
  input.remove();
  return ok;
}

function truncateText(value, limit = 140) {
  const text = String(value ?? '');
  return text.length > limit ? `${text.slice(0, limit - 1)}…` : text;
}

function renderPills(items, mapper) {
  if (!items || items.length === 0) {
    return '<span class="pill warning">لا يوجد</span>';
  }

  return `<div class="pill-row">${items.map((item) => `<span class="pill">${escapeHtml(mapper(item))}</span>`).join('')}</div>`;
}

function parseErrorMessage(error) {
  try {
    const parsed = JSON.parse(error.message);
    if (typeof parsed.message === 'string') {
      return translateKnownMessage(parsed.message);
    }

    if (Array.isArray(parsed.message)) {
      return parsed.message.map((item) => translateKnownMessage(item)).join('، ');
    }
  } catch {
    return translateKnownMessage(error.message);
  }

  return translateKnownMessage(error.message);
}

function getRuleDefinition(ruleType) {
  return CAMPAIGN_RULE_TYPES.find((item) => item.value === ruleType) ?? CAMPAIGN_RULE_TYPES[0];
}

function createDefaultCampaignRule() {
  return {
    id: `${Date.now()}-${Math.random().toString(16).slice(2)}`,
    ruleType: 'group',
    operator: 'eq',
    valueString: '',
    valueJson: '',
    groupId: '',
    tagId: '',
    isExclude: false,
  };
}

function normalizeRuleDraft(rule) {
  const definition = getRuleDefinition(rule.ruleType);
  return {
    ...rule,
    operator: definition.operatorLocked ? definition.operator : (rule.operator || 'eq'),
  };
}

function formatRuleSummary(rule) {
  const definition = getRuleDefinition(rule.ruleType);
  const scopeLabel = rule.isExclude ? 'استبعاد' : 'تضمين';
  const operatorLabel = CAMPAIGN_OPERATORS.find((item) => item.value === rule.operator)?.label ?? rule.operator;

  if (definition.valueMode === 'group') {
    const group = state.groups.find((item) => String(item.id) === String(rule.groupId));
    return `${scopeLabel} مجموعة: ${group?.name ?? 'غير محدد'}`;
  }

  if (definition.valueMode === 'tag') {
    const tag = state.tags.find((item) => String(item.id) === String(rule.tagId));
    return `${scopeLabel} وسم: ${tag?.name ?? 'غير محدد'}`;
  }

  if (rule.operator === 'in') {
    return `${scopeLabel} ${definition.label} ضمن ${rule.valueJson || '[]'}`;
  }

  return `${scopeLabel} ${definition.label} ${operatorLabel} ${rule.valueString || '...'}`;
}

function serializeCampaignRules() {
  return state.campaignRuleDrafts.map((rule) => {
    const definition = getRuleDefinition(rule.ruleType);
    const payload = {
      rule_type: rule.ruleType,
      operator: definition.operatorLocked ? definition.operator : rule.operator,
      is_exclude: Boolean(rule.isExclude),
    };

    if (definition.valueMode === 'group') {
      payload.group_id = Number(rule.groupId);
      return payload;
    }

    if (definition.valueMode === 'tag') {
      payload.tag_id = Number(rule.tagId);
      return payload;
    }

    if (payload.operator === 'in') {
      const values = String(rule.valueJson || '')
        .split(',')
        .map((item) => item.trim())
        .filter(Boolean);
      payload.value_json = values;
      return payload;
    }

    payload.value_string = String(rule.valueString || '').trim();
    return payload;
  });
}

function deserializeCampaignRule(rule) {
  return normalizeRuleDraft({
    id: `existing-${rule.id}`,
    ruleType: rule.rule_type,
    operator: rule.operator || 'eq',
    valueString: rule.value_string || '',
    valueJson: Array.isArray(rule.value_json) ? rule.value_json.join(',') : '',
    groupId: rule.group?.id ? String(rule.group.id) : '',
    tagId: rule.tag?.id ? String(rule.tag.id) : '',
    isExclude: Boolean(rule.is_exclude),
  });
}

function toDateTimeLocal(value) {
  if (!value) {
    return '';
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return '';
  }

  const shifted = new Date(date.getTime() - (date.getTimezoneOffset() * 60000));
  return shifted.toISOString().slice(0, 16);
}

function resetCampaignForm() {
  state.editingCampaignId = null;
  forms.campaign.reset();
  forms.campaign.querySelector('[name="channel"]').value = 'stable';
  forms.campaign.querySelector('[name="priority"]').value = '100';
  forms.campaign.querySelector('[name="rollout_percent"]').value = '100';
  forms.campaign.querySelector('[name="active"]').checked = true;
  state.campaignRuleDrafts = [createDefaultCampaignRule()];
  elements.campaignFormTitle.textContent = 'إنشاء حملة';
  elements.campaignSubmitButton.textContent = 'إنشاء حملة';
  elements.cancelCampaignEditButton.hidden = true;
  renderCampaignRuleBuilder();
}

function startCampaignEdit(campaignId) {
  const campaign = state.campaigns.find((item) => item.id === campaignId);
  if (!campaign) {
    return;
  }

  state.editingCampaignId = campaign.id;
  forms.campaign.querySelector('[name="release_id"]').value = String(campaign.release.id);
  forms.campaign.querySelector('[name="name"]').value = campaign.name;
  forms.campaign.querySelector('[name="channel"]').value = campaign.channel;
  forms.campaign.querySelector('[name="priority"]').value = String(campaign.priority);
  forms.campaign.querySelector('[name="rollout_percent"]').value = String(campaign.rollout_percent);
  forms.campaign.querySelector('[name="start_at"]').value = toDateTimeLocal(campaign.start_at);
  forms.campaign.querySelector('[name="end_at"]').value = toDateTimeLocal(campaign.end_at);
  forms.campaign.querySelector('[name="active"]').checked = campaign.active;
  forms.campaign.querySelector('[name="description"]').value = campaign.description || '';
  state.campaignRuleDrafts = campaign.rules.length > 0
    ? campaign.rules.map((rule) => deserializeCampaignRule(rule))
    : [];
  elements.campaignFormTitle.textContent = `تعديل الحملة #${campaign.id}`;
  elements.campaignSubmitButton.textContent = 'تحديث الحملة';
  elements.cancelCampaignEditButton.hidden = false;
  renderCampaignRuleBuilder();
  forms.campaign.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function renderCampaignRuleBuilder() {
  if (state.campaignRuleDrafts.length === 0) {
    elements.campaignRuleList.innerHTML = '<div class="empty-state">لا توجد قواعد بعد. ستستهدف هذه الحملة كل الأجهزة ضمن نموذج الإصدار المحدد.</div>';
    elements.campaignRulesPreview.innerHTML = '<span class="pill subtle">كل الأجهزة ضمن نطاق الإصدار المحدد</span>';
    return;
  }

  const groupOptions = [{ value: '', label: 'اختر مجموعة…' }, ...state.groups.map((group) => ({
    value: group.id,
    label: `${group.name} (#${group.id})`,
  }))];
  const tagOptions = [{ value: '', label: 'اختر وسمًا…' }, ...state.tags.map((tag) => ({
    value: tag.id,
    label: `${tag.name} (#${tag.id})`,
  }))];

  elements.campaignRuleList.innerHTML = state.campaignRuleDrafts.map((rule) => {
    const definition = getRuleDefinition(rule.ruleType);
    const operatorOptions = definition.operatorLocked
      ? `<option value="${escapeHtml(definition.operator)}">${escapeHtml(CAMPAIGN_OPERATORS.find((item) => item.value === definition.operator)?.label ?? definition.operator)}</option>`
      : optionMarkup(CAMPAIGN_OPERATORS, rule.operator);

    let valueControl = '';

    if (definition.valueMode === 'group') {
      valueControl = `
        <label>
          <span>المجموعة</span>
          <select data-rule-field="groupId" data-rule-id="${escapeHtml(rule.id)}">${optionMarkup(groupOptions, rule.groupId)}</select>
        </label>
      `;
    } else if (definition.valueMode === 'tag') {
      valueControl = `
        <label>
          <span>الوسم</span>
          <select data-rule-field="tagId" data-rule-id="${escapeHtml(rule.id)}">${optionMarkup(tagOptions, rule.tagId)}</select>
        </label>
      `;
    } else if (rule.operator === 'in') {
      valueControl = `
        <label>
          <span>قيم مفصولة بفواصل</span>
          <input data-rule-field="valueJson" data-rule-id="${escapeHtml(rule.id)}" value="${escapeHtml(rule.valueJson)}" placeholder="v1,v2,v3">
        </label>
      `;
    } else {
      valueControl = `
        <label>
          <span>القيمة</span>
          <input data-rule-field="valueString" data-rule-id="${escapeHtml(rule.id)}" value="${escapeHtml(rule.valueString)}" placeholder="أدخل قيمة المطابقة">
        </label>
      `;
    }

    return `
      <div class="rule-builder-row">
        <label>
          <span>النطاق</span>
          <select data-rule-field="isExclude" data-rule-id="${escapeHtml(rule.id)}">
            <option value="false"${rule.isExclude ? '' : ' selected'}>تضمين</option>
            <option value="true"${rule.isExclude ? ' selected' : ''}>استبعاد</option>
          </select>
        </label>
        <label>
          <span>نوع القاعدة</span>
          <select data-rule-field="ruleType" data-rule-id="${escapeHtml(rule.id)}">${optionMarkup(CAMPAIGN_RULE_TYPES.map((item) => ({ value: item.value, label: item.label })), rule.ruleType)}</select>
        </label>
        <label>
          <span>المعامل</span>
          <select data-rule-field="operator" data-rule-id="${escapeHtml(rule.id)}"${definition.operatorLocked ? ' disabled' : ''}>${operatorOptions}</select>
        </label>
        ${valueControl}
        <div></div>
        <button class="secondary-button" type="button" data-rule-action="remove" data-rule-id="${escapeHtml(rule.id)}">حذف</button>
      </div>
    `;
  }).join('');

  elements.campaignRulesPreview.innerHTML = state.campaignRuleDrafts
    .map((rule) => `<span class="pill">${escapeHtml(formatRuleSummary(rule))}</span>`)
    .join('');
}

function filterDevices() {
  const query = state.deviceSearch.trim().toLowerCase();
  if (!query) {
    return state.devices;
  }

  return state.devices.filter((device) => {
    const haystack = [
      device.id,
      device.model,
      device.board,
      device.mac,
      device.token,
      tokenTail(device.token),
      device.last_ip,
      device.last_result,
      device.current_version,
      device.status,
      device.firmware_model?.display_name,
      ...(device.groups || []).map((group) => group.name),
      ...(device.tags || []).map((tag) => tag.name),
    ]
      .filter(Boolean)
      .join(' ')
      .toLowerCase();

    return haystack.includes(query);
  });
}

function filterReleases() {
  if (!state.releaseFilterModelId) {
    return state.releases;
  }

  return state.releases.filter((release) => String(release.firmware_model?.id ?? '') === String(state.releaseFilterModelId));
}



function tableMarkup(headers, rows) {
  if (rows.length === 0) {
    return '<div class="empty-state">لا توجد سجلات بعد.</div>';
  }

  return `
    <table>
      <thead>
        <tr>${headers.map((header) => `<th>${escapeHtml(header)}</th>`).join('')}</tr>
      </thead>
      <tbody>
        ${rows.join('')}
      </tbody>
    </table>
  `;
}

async function refreshSession() {
  if (!state.refreshToken) {
    throw new Error('No refresh token available');
  }

  const response = await fetch(`${API_BASE}/admin/auth/refresh`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ refresh_token: state.refreshToken }),
  });

  if (!response.ok) {
    clearSession();
    throw new Error('Session expired');
  }

  const payload = await response.json();
  setSession(payload);
}

async function apiFetch(path, options = {}, allowRetry = true) {
  const headers = new Headers(options.headers || {});

  if (state.accessToken) {
    headers.set('Authorization', `Bearer ${state.accessToken}`);
  }

  if (options.body && !(options.body instanceof FormData) && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json');
  }

  const response = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers,
  });

  if (response.status === 401 && allowRetry && state.refreshToken) {
    await refreshSession();
    return apiFetch(path, options, false);
  }

  if (!response.ok) {
    if (response.status === 413) {
      throw new Error('Payload too large');
    }

    const text = await response.text();
    throw new Error(text || `فشل الطلب برمز الحالة ${response.status}`);
  }

  return response.status === 204 ? null : response.json();
}

function setSession(payload) {
  state.accessToken = payload.access_token;
  state.refreshToken = payload.refresh_token;
  state.admin = payload.admin ?? null;
  localStorage.setItem('ota_admin_access_token', state.accessToken);
  localStorage.setItem('ota_admin_refresh_token', state.refreshToken);
  updateSessionChrome();
}

function clearSession() {
  state.accessToken = '';
  state.refreshToken = '';
  state.admin = null;
  localStorage.removeItem('ota_admin_access_token');
  localStorage.removeItem('ota_admin_refresh_token');
  updateSessionChrome();
}

function updateSessionChrome() {
  const signedIn = Boolean(state.accessToken);
  elements.loginPanel.hidden = signedIn;
  elements.appPanel.hidden = !signedIn;
  elements.refreshButton.hidden = !signedIn;
  elements.logoutButton.hidden = !signedIn;
  const roleLabel = state.admin?.role === 'admin' ? 'مشرف' : (state.admin?.role ?? '');
  elements.sessionBadge.textContent = signedIn && state.admin
    ? `${state.admin.email} • ${roleLabel}`
    : 'غير مسجل الدخول';
  elements.sessionBadge.classList.toggle('muted', !signedIn);
}

function collectFormData(form) {
  const formData = new FormData(form);
  return Object.fromEntries(formData.entries());
}

function normalizeArtifactPathInput(value) {
  const cleaned = String(value ?? '').trim();
  if (!cleaned) {
    return '';
  }

  const unixPath = cleaned
    .replace(/\\/g, '/')
    .replace(/^\/+/, '')
    .replace(/\/+/g, '/')
    .replace(/\/+$/, '');

  return unixPath ? `/${unixPath}` : '';
}

function getFieldLabel(field) {
  if (!(field instanceof HTMLElement)) {
    return 'حقل مطلوب';
  }

  const labelElement = field.closest('label')?.querySelector('span');
  if (labelElement?.textContent?.trim()) {
    return labelElement.textContent.trim();
  }

  return field.getAttribute('name') || 'حقل مطلوب';
}

function setReleaseSubmitState(isSubmitting) {
  const submitButton = forms.release?.querySelector('button[type="submit"]');
  if (!submitButton) {
    return;
  }

  if (!submitButton.dataset.idleText) {
    submitButton.dataset.idleText = submitButton.textContent || 'إنشاء إصدار';
  }

  submitButton.disabled = isSubmitting;
  submitButton.textContent = isSubmitting ? 'جارٍ إنشاء الإصدار...' : submitButton.dataset.idleText;
}

function hydrateSelect(selectElement, items, mapper, includeEmpty = true) {
  const currentValue = selectElement.value;
  const options = [];

  if (includeEmpty) {
    options.push('<option value="">اختر…</option>');
  }

  for (const item of items) {
    const option = mapper(item);
    options.push(`<option value="${escapeHtml(option.value)}">${escapeHtml(option.label)}</option>`);
  }

  selectElement.innerHTML = options.join('');
  if (currentValue) {
    selectElement.value = currentValue;
  }
}

function renderSummary() {
  const counts = state.summary?.counts;
  if (!counts) {
    elements.summaryGrid.innerHTML = '';
    return;
  }

  const cards = [
    { label: 'إجمالي الأجهزة', value: counts.total_devices, note: 'كل الموجهات المسجلة' },
    { label: 'شوهدت خلال 24 ساعة', value: counts.online_last_24h, note: 'أجهزة نشطة مؤخرًا' },
    { label: 'الحملات النشطة', value: counts.active_campaigns, note: 'عمليات نشر جارية' },
    { label: 'نماذج البرامج الثابتة', value: counts.firmware_models, note: 'أنواع الأجهزة المدارة' },
  ];

  elements.summaryGrid.innerHTML = cards.map((card) => `
    <article class="summary-card">
      <p class="eyebrow">${escapeHtml(card.label)}</p>
      <h3>${escapeHtml(card.value)}</h3>
      <p>${escapeHtml(card.note)}</p>
    </article>
  `).join('');
}

function renderDevices() {
  const rows = filterDevices().map((device) => `
    <tr>
      <td class="mono">${escapeHtml(device.id)}</td>
      <td class="device-cell">
        <strong>${escapeHtml(device.firmware_model?.display_name ?? device.model)}</strong><br>
        <span class="mono">${escapeHtml(device.model)}</span><br>
        <span class="muted-line">Board: <span class="mono">${escapeHtml(device.board ?? '-')}</span></span>
      </td>
      <td class="mono">${escapeHtml(device.mac ?? '-')}</td>
      <td class="mono">${escapeHtml(device.last_ip ?? '-')}</td>
      <td class="mono">${escapeHtml(tokenTail(device.token))}</td>
      <td class="mono">${escapeHtml(device.current_version ?? '-')}</td>
      <td>
        ${escapeHtml(translateValue(device.status, DEVICE_STATUS_LABELS))}<br>
        <span class="muted-line">${escapeHtml(device.last_result ?? '-')}</span>
      </td>
      <td>${formatDate(device.last_seen_at)}</td>
      <td>
        <span class="pill ${device.hotspot_licensed ? 'success' : 'muted'}">${device.hotspot_licensed ? 'مرخص' : 'غير مرخص'}</span>
        <button type="button" class="link-button" data-hotspot-license-device="${escapeHtml(device.id)}" data-hotspot-license-next="${device.hotspot_licensed ? 'false' : 'true'}">
          ${device.hotspot_licensed ? 'إلغاء الترخيص' : 'ترخيص الهوتسبوت'}
        </button>
      </td>
      <td>${renderPills(device.groups, (group) => group.name)}</td>
      <td>${renderPills(device.tags, (tag) => tag.name)}</td>
      <td>${escapeHtml(device.last_error ?? '-')}</td>
    </tr>
  `);

  elements.devicesTable.innerHTML = tableMarkup(
    ['المعرف', 'الجهاز', 'MAC', 'IP', 'آخر التوكن', 'الإصدار', 'الحالة/النتيجة', 'آخر ظهور', 'ترخيص الهوتسبوت', 'المجموعات', 'الوسوم', 'آخر خطأ'],
    rows,
  );
}

function renderModels() {
  const rows = state.models.map((model) => `
    <tr>
      <td class="mono">${escapeHtml(model.id)}</td>
      <td>${escapeHtml(model.display_name)}</td>
      <td class="mono">${escapeHtml(model.model_key)}</td>
      <td class="mono">${escapeHtml(model.board_identifier ?? '-')}</td>
      <td>${escapeHtml(model.device_count)}</td>
      <td>${escapeHtml(model.release_count)}</td>
    </tr>
  `);

  elements.modelsTable.innerHTML = tableMarkup(
    ['المعرف', 'الاسم المعروض', 'مفتاح الطراز', 'اللوحة', 'الأجهزة', 'الإصدارات'],
    rows,
  );
}

function renderGroups() {
  const rows = state.groups.map((group) => `
    <tr>
      <td class="mono">${escapeHtml(group.id)}</td>
      <td>${escapeHtml(group.name)}</td>
      <td>${escapeHtml(group.member_count)}</td>
    </tr>
  `);

  elements.groupsTable.innerHTML = tableMarkup(['المعرف', 'المجموعة', 'الأعضاء'], rows);
}

function renderTags() {
  const rows = state.tags.map((tag) => `
    <tr>
      <td class="mono">${escapeHtml(tag.id)}</td>
      <td>${escapeHtml(tag.name)}</td>
      <td>${escapeHtml(tag.member_count)}</td>
    </tr>
  `);

  elements.tagsTable.innerHTML = tableMarkup(['المعرف', 'الوسم', 'الأعضاء'], rows);
}

function renderReleases() {
  const rows = filterReleases().map((release) => {
    const file = releasePrimaryFile(release);
    const sourceLabel = /^https?:\/\//i.test(release.download_url || '') ? 'رابط خارجي' : 'ملف محلي';
    const actionButtons = [
      `<button class="table-action-button active" type="button" data-release-action="details" data-release-id="${escapeHtml(release.id)}">تفاصيل</button>`,
      `<button class="table-action-button" type="button" data-release-action="copy" data-release-id="${escapeHtml(release.id)}">نسخ الرابط</button>`,
      `<button class="table-action-button" type="button" data-release-action="download" data-release-id="${escapeHtml(release.id)}">تنزيل</button>`,
      `<button class="table-action-button" type="button" data-release-action="${release.active ? 'pause' : 'activate'}" data-release-id="${escapeHtml(release.id)}">${release.active ? 'تعطيل' : 'تفعيل'}</button>`,
      `<button class="table-action-button" type="button" data-release-action="campaign" data-release-id="${escapeHtml(release.id)}">حملة</button>`,
      `<button class="table-action-button danger" type="button" data-release-action="delete" data-release-id="${escapeHtml(release.id)}">حذف</button>`,
    ];

    return `
      <tr>
        <td class="mono">${escapeHtml(release.id)}</td>
        <td>
          <strong>${escapeHtml(release.version)}</strong><br>
          <span class="muted-line mono">${escapeHtml(release.version_code || '-')}</span><br>
          <span class="muted-line">${escapeHtml(formatDate(release.created_at))}</span>
        </td>
        <td>
          <strong>${escapeHtml(release.firmware_model?.display_name ?? release.model)}</strong><br>
          <span class="mono">${escapeHtml(release.model)}</span>
        </td>
        <td>
          ${escapeHtml(release.channel)}<br>
          <span class="muted-line">${escapeHtml(sourceLabel)}</span>
        </td>
        <td>
          ${release.active ? '<span class="pill">نشط</span>' : '<span class="pill warning">غير نشط</span>'}
          ${release.force ? '<span class="pill warning">إجباري</span>' : ''}
        </td>
        <td>
          <span>${escapeHtml(formatBytes(file?.size_bytes))}</span><br>
          <span class="muted-line">${escapeHtml(fileNameFromUrl(file?.url || release.download_url))}</span><br>
          <span class="muted-line">حملات: ${escapeHtml(release.campaign_count ?? 0)}</span>
        </td>
        <td class="mono" title="${escapeHtml(release.sha256)}">${escapeHtml(String(release.sha256 || '').slice(0, 12))}…</td>
        <td><div class="table-actions">${actionButtons.join('')}</div></td>
      </tr>
    `;
  });

  elements.releasesTable.innerHTML = tableMarkup(
    ['المعرف', 'الإصدار', 'نموذج البرنامج الثابت', 'القناة', 'الحالة', 'الحجم/الاستخدام', 'SHA256', 'إجراءات'],
    rows,
  );
}

function findRelease(releaseId) {
  return state.releases.find((release) => String(release.id) === String(releaseId));
}

function showReleaseDetails(release) {
  const file = releasePrimaryFile(release);
  window.alert([
    `الإصدار: ${release.version}`,
    `الطراز: ${release.firmware_model?.display_name ?? release.model}`,
    `مفتاح الطراز: ${release.model}`,
    `القناة: ${release.channel}`,
    `الحالة: ${release.active ? 'نشط' : 'غير نشط'}`,
    `الحجم: ${formatBytes(file?.size_bytes)}`,
    `اسم الملف: ${fileNameFromUrl(file?.url || release.download_url)}`,
    `SHA256: ${release.sha256}`,
    `الرابط: ${release.download_url}`,
    `الحملات المرتبطة: ${release.campaign_count ?? 0}`,
    `تاريخ الإنشاء: ${formatDate(release.created_at)}`,
    `سجل التغييرات: ${release.changelog || '-'}`,
  ].join('\n'));
}

async function setReleaseActive(releaseId, active) {
  setMessage(active ? 'جارٍ تفعيل الإصدار...' : 'جارٍ تعطيل الإصدار...');
  await apiFetch(`/admin/releases/${releaseId}/${active ? 'activate' : 'pause'}`, { method: 'POST' });
  await refreshData();
  setMessage(active ? 'تم تفعيل الإصدار.' : 'تم تعطيل الإصدار.', 'success');
}

async function deleteRelease(releaseId) {
  const release = findRelease(releaseId);
  if (!release) {
    return;
  }

  if ((release.campaign_count ?? 0) > 0) {
    window.alert('هذا الإصدار مرتبط بحملات. لا يتم حذفه حتى لا تُحذف الحملات المرتبطة به. استخدم تعطيل الإصدار أو احذف الحملات أولاً.');
    return;
  }

  if (!window.confirm(`سيتم حذف الإصدار ${release.version} من لوحة OTA. هل أنت متأكد؟`)) {
    return;
  }

  setMessage('جارٍ حذف الإصدار...');
  await apiFetch(`/admin/releases/${releaseId}`, { method: 'DELETE' });
  await refreshData();
  setMessage('تم حذف الإصدار.', 'success');
}

function renderCampaigns() {
  const rows = state.campaigns.map((campaign) => {
    const stateMarkup = campaign.archived_at
      ? '<span class="pill subtle">مؤرشفة</span>'
      : (campaign.active ? '<span class="pill">مفعلة</span>' : '<span class="pill warning">متوقفة</span>');
    const actionButtons = [];

    if (!campaign.archived_at) {
      actionButtons.push(`<button class="table-action-button" type="button" data-campaign-action="edit" data-campaign-id="${escapeHtml(campaign.id)}">تعديل</button>`);
    }

    actionButtons.push(`<button class="table-action-button active" type="button" data-campaign-action="inspect" data-campaign-id="${escapeHtml(campaign.id)}">استعراض</button>`);

    if (!campaign.archived_at) {
      actionButtons.push(`<button class="table-action-button" type="button" data-campaign-action="${campaign.active ? 'pause' : 'activate'}" data-campaign-id="${escapeHtml(campaign.id)}">${campaign.active ? 'إيقاف' : 'تفعيل'}</button>`);
      actionButtons.push(`<button class="table-action-button" type="button" data-campaign-action="archive" data-campaign-id="${escapeHtml(campaign.id)}">أرشفة</button>`);
    }

    actionButtons.push(`<button class="table-action-button" type="button" data-campaign-action="delete" data-campaign-id="${escapeHtml(campaign.id)}">حذف</button>`);

    return `
      <tr class="${state.selectedCampaignId === campaign.id ? 'campaign-row-selected' : ''}">
        <td class="mono">${escapeHtml(campaign.id)}</td>
        <td>
          <strong>${escapeHtml(campaign.name)}</strong><br>
          <span class="mono">${escapeHtml(campaign.release.version)}</span>
        </td>
        <td>${escapeHtml(campaign.release.firmware_model?.display_name ?? campaign.release.model)}</td>
        <td>${escapeHtml(campaign.priority)}</td>
        <td>${escapeHtml(campaign.rollout_percent)}%</td>
        <td>${stateMarkup}</td>
        <td>${renderPills(campaign.rules, (rule) => {
      const ruleLabel = getRuleDefinition(rule.rule_type).label;
      const suffix = rule.group?.name ?? rule.tag?.name ?? rule.value_string ?? rule.operator;
      return `${ruleLabel}: ${suffix}`;
    })}</td>
        <td>
          <div class="table-actions">
            ${actionButtons.join('')}
          </div>
        </td>
      </tr>
    `;
  });

  elements.campaignsTable.innerHTML = tableMarkup(
    ['المعرف', 'الحملة', 'نموذج البرنامج الثابت', 'الأولوية', 'نسبة الإطلاق', 'الحالة', 'القواعد', 'الإجراءات'],
    rows,
  );
}

function renderCampaignDevices() {
  const selectedCampaign = state.campaigns.find((campaign) => campaign.id === state.selectedCampaignId);

  if (!state.selectedCampaignId || !selectedCampaign) {
    elements.campaignDetailsPanel.hidden = true;
    elements.campaignDevicesTable.innerHTML = '';
    elements.campaignDetailsTitle.textContent = 'أجهزة الحملة';
    elements.campaignDetailsMeta.textContent = 'اختر حملة لاستعراض الأجهزة المتتبعة.';
    return;
  }

  elements.campaignDetailsPanel.hidden = false;
  elements.campaignDetailsTitle.textContent = `${selectedCampaign.name} - حالات الأجهزة`;
  elements.campaignDetailsMeta.textContent = selectedCampaign
    ? `${selectedCampaign.release.version} • ${state.campaignDevices.length} جهازًا متتبعًا`
    : `${state.campaignDevices.length} جهازًا متتبعًا`;

  const rows = state.campaignDevices.map((entry) => `
    <tr>
      <td class="mono">${escapeHtml(entry.device.id)}</td>
      <td>
        <strong>${escapeHtml(entry.device.firmware_model?.display_name ?? entry.device.model)}</strong><br>
        <span class="mono">${escapeHtml(entry.device.mac)}</span>
      </td>
      <td>${escapeHtml(translateValue(entry.eligibility_status, ELIGIBILITY_STATUS_LABELS))}</td>
      <td>${escapeHtml(translateValue(entry.update_status, UPDATE_STATUS_LABELS))}</td>
      <td>${formatDate(entry.matched_at)}</td>
      <td>${formatDate(entry.delivered_at)}</td>
      <td>${formatDate(entry.last_evaluated_at)}</td>
    </tr>
  `);

  elements.campaignDevicesTable.innerHTML = tableMarkup(
    ['معرف الجهاز', 'الجهاز', 'الأهلية', 'حالة التحديث', 'وقت المطابقة', 'وقت التسليم', 'آخر تقييم'],
    rows,
  );
}

function renderAuditLogs() {
  const rows = state.auditLogs.map((log) => `
    <tr>
      <td class="mono">${escapeHtml(log.id)}</td>
      <td>${escapeHtml(log.action)}</td>
      <td>${escapeHtml(log.entity_type)}</td>
      <td class="mono">${escapeHtml(log.entity_id ?? '-')}</td>
      <td>${escapeHtml(log.admin_user?.email ?? 'النظام')}</td>
      <td class="audit-payload">${escapeHtml(truncateText(JSON.stringify(log.payload_json ?? {}), 220))}</td>
      <td>${formatDate(log.created_at)}</td>
    </tr>
  `);

  elements.auditLogsTable.innerHTML = tableMarkup(
    ['المعرف', 'الإجراء', 'الكيان', 'معرف الكيان', 'المنفذ', 'الحمولة', 'وقت الإنشاء'],
    rows,
  );
}

function refreshSelectors() {
  // If the /admin/models endpoint failed or returned empty, derive models from
  // the firmware_model objects embedded in releases (which always load).
  let modelList = state.models;
  if (modelList.length === 0 && state.releases.length > 0) {
    const seen = new Map();
    for (const r of state.releases) {
      if (r.firmware_model?.id != null && !seen.has(r.firmware_model.id)) {
        seen.set(r.firmware_model.id, r.firmware_model);
      }
    }
    modelList = [...seen.values()];
    if (modelList.length > 0) {
      console.warn('[OTA] state.models was empty — derived', modelList.length, 'models from releases as fallback');
    }
  }

  // Debug info — visible in browser console (F12)
  console.log('[OTA] refreshSelectors: models=', modelList.length, 'releases=', state.releases.length);

  hydrateSelect(elements.releaseModelSelect, modelList, (model) => ({
    value: model.id,
    label: `${model.display_name ?? model.displayName} • ${model.model_key ?? model.modelKey}`,
  }));

  hydrateSelect(elements.releaseFilterSelect, modelList, (model) => ({
    value: model.id,
    label: `${model.display_name ?? model.displayName} • ${model.model_key ?? model.modelKey}`,
  }));

  hydrateSelect(elements.campaignReleaseSelect, state.releases, (release) => ({
    value: release.id,
    label: `${release.version} • ${release.firmware_model?.display_name ?? release.model}`,
  }), false);

  hydrateSelect(elements.assignGroupSelect, state.groups, (group) => ({
    value: group.id,
    label: `${group.name} (#${group.id})`,
  }), false);

  hydrateSelect(elements.assignTagSelect, state.tags, (tag) => ({
    value: tag.id,
    label: `${tag.name} (#${tag.id})`,
  }), false);

  renderCampaignRuleBuilder();
}

function renderAll() {
  renderSummary();
  renderDevices();
  renderModels();
  renderGroups();
  renderTags();
  renderReleases();
  renderCampaigns();
  renderCampaignDevices();
  renderAuditLogs();
  refreshSelectors();
}

async function loadCampaignDevices(campaignId) {
  state.selectedCampaignId = campaignId;
  renderCampaigns();
  renderCampaignDevices();
  setMessage('جارٍ تحميل أجهزة الحملة...');

  try {
    state.campaignDevices = await apiFetch(`/admin/campaigns/${campaignId}/devices`);
    renderCampaignDevices();
    setMessage('تم تحميل حالات أجهزة الحملة.');
  } catch (error) {
    state.campaignDevices = [];
    renderCampaignDevices();
    setMessage(parseErrorMessage(error), 'warning');
  }
}

async function toggleCampaignState(campaignId, action) {
  const path = action === 'pause' ? 'pause' : 'activate';
  setMessage(action === 'pause' ? 'جارٍ إيقاف الحملة...' : 'جارٍ تفعيل الحملة...');
  await apiFetch(`/admin/campaigns/${campaignId}/${path}`, { method: 'POST' });
  await refreshData();
  if (state.selectedCampaignId === campaignId) {
    await loadCampaignDevices(campaignId);
  }
}

async function archiveCampaign(campaignId) {
  setMessage('جارٍ أرشفة الحملة...');
  await apiFetch(`/admin/campaigns/${campaignId}/archive`, { method: 'POST' });
  if (state.selectedCampaignId === campaignId && !state.showArchivedCampaigns) {
    state.selectedCampaignId = null;
    state.campaignDevices = [];
  }
  if (state.editingCampaignId === campaignId) {
    resetCampaignForm();
  }
  await refreshData();
}

async function deleteCampaign(campaignId) {
  setMessage('جارٍ حذف الحملة...');
  await apiFetch(`/admin/campaigns/${campaignId}`, { method: 'DELETE' });
  if (state.selectedCampaignId === campaignId) {
    state.selectedCampaignId = null;
    state.campaignDevices = [];
  }
  if (state.editingCampaignId === campaignId) {
    resetCampaignForm();
  }
  await refreshData();
}

async function refreshData() {
  setMessage('جارٍ تحديث بيانات لوحة التحكم...');

  const campaignPath = state.showArchivedCampaigns ? '/admin/campaigns?include_archived=true' : '/admin/campaigns';

  // Use allSettled so a single failing endpoint does NOT wipe the other data
  const results = await Promise.allSettled([
    apiFetch('/admin/dashboard'),
    apiFetch('/admin/devices'),
    apiFetch('/admin/models'),
    apiFetch('/admin/groups'),
    apiFetch('/admin/tags'),
    apiFetch('/admin/releases'),
    apiFetch(campaignPath),
    apiFetch('/admin/audit-logs?limit=50'),
  ]);

  const [summary, devices, models, groups, tags, releases, campaigns, auditLogs] = results;

  if (summary.status === 'fulfilled')    state.summary   = summary.value ?? state.summary;
  if (devices.status === 'fulfilled')    state.devices   = Array.isArray(devices.value)  ? devices.value  : state.devices;
  if (models.status  === 'fulfilled')    state.models    = Array.isArray(models.value)   ? models.value   : state.models;
  if (groups.status  === 'fulfilled')    state.groups    = Array.isArray(groups.value)   ? groups.value   : state.groups;
  if (tags.status    === 'fulfilled')    state.tags      = Array.isArray(tags.value)    ? tags.value    : state.tags;
  if (releases.status === 'fulfilled')   state.releases  = Array.isArray(releases.value) ? releases.value : state.releases;
  if (campaigns.status === 'fulfilled')  state.campaigns = Array.isArray(campaigns.value)? campaigns.value: state.campaigns;
  if (auditLogs.status === 'fulfilled')  state.auditLogs = Array.isArray(auditLogs.value)? auditLogs.value: state.auditLogs;

  if (!state.campaigns.some((campaign) => campaign.id === state.selectedCampaignId)) {
    state.selectedCampaignId = null;
    state.campaignDevices = [];
  }
  if (state.editingCampaignId != null && !state.campaigns.some((campaign) => campaign.id === state.editingCampaignId)) {
    resetCampaignForm();
  }
  renderAll();

  const failures = results.filter((r) => r.status === 'rejected');
  if (failures.length > 0) {
    setMessage(`تمت المزامنة مع ${results.length - failures.length}/${results.length} طلبات (${failures.length} فشل).`, 'warning');
  } else {
    setMessage('تمت مزامنة لوحة التحكم.');
  }
}


async function initializeSession() {
  if (!state.accessToken) {
    updateSessionChrome();
    return;
  }

  try {
    state.admin = await apiFetch('/admin/auth/me', { method: 'GET' });
    updateSessionChrome();
    await refreshData();
  } catch (error) {
    clearSession();
    updateSessionChrome();
    setMessage(parseErrorMessage(error), 'warning', elements.loginMessage);
  }
}

elements.loginForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setMessage('جارٍ تسجيل الدخول...', 'muted', elements.loginMessage);

  try {
    const payload = collectFormData(elements.loginForm);
    const response = await fetch(`${API_BASE}/admin/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new Error(await response.text());
    }

    const session = await response.json();
    setSession(session);
    elements.loginForm.reset();
    setMessage('تم التحقق بنجاح.', 'muted', elements.loginMessage);
    await refreshData();
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning', elements.loginMessage);
  }
});

elements.refreshButton.addEventListener('click', async () => {
  try {
    await refreshData();
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning');
  }
});

elements.logoutButton.addEventListener('click', async () => {
  try {
    if (state.refreshToken) {
      await fetch(`${API_BASE}/admin/auth/logout`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh_token: state.refreshToken }),
      });
    }
  } finally {
    clearSession();
    setMessage('تم تسجيل الخروج.', 'muted', elements.loginMessage);
  }
});

forms.model.addEventListener('submit', async (event) => {
  event.preventDefault();
  try {
    await apiFetch('/admin/models', {
      method: 'POST',
      body: JSON.stringify(collectFormData(forms.model)),
    });
    forms.model.reset();
    await refreshData();
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning');
  }
});

forms.group.addEventListener('submit', async (event) => {
  event.preventDefault();
  try {
    await apiFetch('/admin/groups', {
      method: 'POST',
      body: JSON.stringify(collectFormData(forms.group)),
    });
    forms.group.reset();
    await refreshData();
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning');
  }
});

forms.tag.addEventListener('submit', async (event) => {
  event.preventDefault();
  try {
    await apiFetch('/admin/tags', {
      method: 'POST',
      body: JSON.stringify(collectFormData(forms.tag)),
    });
    forms.tag.reset();
    await refreshData();
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning');
  }
});

forms.assignGroup.addEventListener('submit', async (event) => {
  event.preventDefault();
  try {
    const data = collectFormData(forms.assignGroup);
    await apiFetch(`/admin/devices/${data.device_id}/groups/${data.group_id}`, {
      method: 'POST',
    });
    forms.assignGroup.reset();
    await refreshData();
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning');
  }
});

forms.assignTag.addEventListener('submit', async (event) => {
  event.preventDefault();
  try {
    const data = collectFormData(forms.assignTag);
    await apiFetch(`/admin/devices/${data.device_id}/tags/${data.tag_id}`, {
      method: 'POST',
    });
    forms.assignTag.reset();
    await refreshData();
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning');
  }
});

forms.release.addEventListener('invalid', (event) => {
  event.preventDefault();
  const label = getFieldLabel(event.target);
  setMessage(`الرجاء إكمال الحقل المطلوب: ${label}.`, 'warning', elements.releaseMessage);
}, true);

forms.release.querySelector('button[type="submit"]')?.addEventListener('click', () => {
  if (forms.release.checkValidity()) {
    return;
  }

  const invalidField = forms.release.querySelector(':invalid');
  setMessage(`الرجاء إكمال الحقل المطلوب: ${getFieldLabel(invalidField)}.`, 'warning', elements.releaseMessage);
});

forms.release.addEventListener('submit', async (event) => {
  event.preventDefault();
  if (state.releaseSubmitting) {
    return;
  }

  state.releaseSubmitting = true;
  setReleaseSubmitState(true);
  setMessage('جارٍ إنشاء الإصدار...', 'muted', elements.releaseMessage);

  try {
    const data = collectFormData(forms.release);
    const artifactFile = forms.release.querySelector('[name="artifact"]').files?.[0] ?? null;
    const artifactPath = normalizeArtifactPathInput(data.artifact_path);
    const artifactUrl = String(data.artifact_url || '').trim();

    // Prefer an explicit server-side artifact path when provided, even if a file was selected.
    if (artifactUrl) {
      const payload = {
        firmware_model_id: data.firmware_model_id ? Number(data.firmware_model_id) : undefined,
        model: data.model || undefined,
        version: data.version,
        version_code: data.version_code || undefined,
        artifact_url: artifactUrl,
        changelog: data.changelog || undefined,
        channel: data.channel || 'stable',
        rollout_percent: Number(data.rollout_percent || 100),
        active: forms.release.querySelector('[name="active"]').checked,
        force: forms.release.querySelector('[name="force"]').checked,
      };

      await apiFetch('/admin/releases', {
        method: 'POST',
        body: JSON.stringify(payload),
      });
    } else if (artifactPath) {
      if (!artifactPath.startsWith('/firmware/')) {
        throw new Error('artifact_path must start with /firmware/');
      }

      const payload = {
        firmware_model_id: data.firmware_model_id ? Number(data.firmware_model_id) : undefined,
        model: data.model || undefined,
        version: data.version,
        version_code: data.version_code || undefined,
        artifact_path: artifactPath,
        changelog: data.changelog || undefined,
        channel: data.channel || 'stable',
        rollout_percent: Number(data.rollout_percent || 100),
        active: forms.release.querySelector('[name="active"]').checked,
        force: forms.release.querySelector('[name="force"]').checked,
      };

      await apiFetch('/admin/releases', {
        method: 'POST',
        body: JSON.stringify(payload),
      });
    } else if (artifactFile) {
      if (artifactFile.size > MAX_BROWSER_UPLOAD_BYTES) {
        throw new Error('Large browser uploads can timeout. Provide a /firmware/ path for this file.');
      }

      const formData = new FormData();
      if (data.firmware_model_id) formData.append('firmware_model_id', data.firmware_model_id);
      if (data.model) formData.append('model', data.model);
      formData.append('version', data.version);
      if (data.version_code) formData.append('version_code', data.version_code);
      if (data.changelog) formData.append('changelog', data.changelog);
      formData.append('channel', data.channel || 'stable');
      formData.append('rollout_percent', String(Number(data.rollout_percent || 100)));
      formData.append('active', forms.release.querySelector('[name="active"]').checked ? 'true' : 'false');
      formData.append('force', forms.release.querySelector('[name="force"]').checked ? 'true' : 'false');
      formData.append('artifact', artifactFile);

      await apiFetch('/admin/releases/upload', {
        method: 'POST',
        body: formData,
      });
    } else {
      throw new Error('artifact_path or artifact_url is required');
    }

    forms.release.reset();
    setMessage('تم إرسال طلب إنشاء الإصدار بنجاح.', 'muted', elements.releaseMessage);
    await refreshData();
  } catch (error) {
    const message = parseErrorMessage(error);
    setMessage(message, 'warning', elements.releaseMessage);
    setMessage(message, 'warning');
  } finally {
    state.releaseSubmitting = false;
    setReleaseSubmitState(false);
  }
});

forms.campaign.addEventListener('submit', async (event) => {
  event.preventDefault();
  try {
    const editingCampaignId = state.editingCampaignId;
    const data = collectFormData(forms.campaign);
    const payload = {
      release_id: Number(data.release_id),
      name: data.name,
      description: data.description || undefined,
      channel: data.channel || 'stable',
      priority: Number(data.priority || 100),
      rollout_percent: Number(data.rollout_percent || 100),
      active: forms.campaign.querySelector('[name="active"]').checked,
      start_at: data.start_at ? new Date(data.start_at).toISOString() : undefined,
      end_at: data.end_at ? new Date(data.end_at).toISOString() : undefined,
      rules: serializeCampaignRules(),
    };

    for (const rule of payload.rules) {
      if ((rule.rule_type === 'group' && !rule.group_id) || (rule.rule_type === 'tag' && !rule.tag_id)) {
        throw new Error('قواعد المجموعة والوسم تتطلب اختيار قيمة.');
      }

      if (rule.rule_type !== 'group' && rule.rule_type !== 'tag' && rule.operator !== 'in' && !rule.value_string) {
        throw new Error(`القاعدة ${getRuleDefinition(rule.rule_type).label} تتطلب قيمة.`);
      }

      if (rule.operator === 'in' && (!Array.isArray(rule.value_json) || rule.value_json.length === 0)) {
        throw new Error(`القاعدة ${getRuleDefinition(rule.rule_type).label} تتطلب قيمة واحدة على الأقل ضمن القائمة.`);
      }
    }

    await apiFetch(editingCampaignId ? `/admin/campaigns/${editingCampaignId}` : '/admin/campaigns', {
      method: editingCampaignId ? 'PATCH' : 'POST',
      body: JSON.stringify(payload),
    });
    resetCampaignForm();
    await refreshData();
    if (editingCampaignId) {
      await loadCampaignDevices(editingCampaignId);
    }
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning');
  }
});

elements.deviceSearchInput.addEventListener('input', (event) => {
  state.deviceSearch = event.target.value;
  renderDevices();
});

elements.devicesTable.addEventListener('click', async (event) => {
  const button = event.target.closest('[data-hotspot-license-device]');
  if (!button) {
    return;
  }

  const deviceId = button.dataset.hotspotLicenseDevice;
  const licensed = button.dataset.hotspotLicenseNext === 'true';

  button.disabled = true;
  try {
    await apiFetch(`/admin/devices/${deviceId}/hotspot-license`, {
      method: 'PATCH',
      body: JSON.stringify({ licensed }),
    });
    setMessage(licensed ? 'تم ترخيص الهوتسبوت لهذا الجهاز.' : 'تم إلغاء ترخيص الهوتسبوت لهذا الجهاز.', 'success');
    await refreshData();
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning');
  } finally {
    button.disabled = false;
  }
});

elements.releaseFilterSelect.addEventListener('change', (event) => {
  state.releaseFilterModelId = event.target.value;
  renderReleases();
});

elements.releasesTable.addEventListener('click', async (event) => {
  const button = event.target.closest('[data-release-action]');
  if (!button) {
    return;
  }

  const release = findRelease(button.dataset.releaseId);
  if (!release) {
    return;
  }

  const action = button.dataset.releaseAction;
  button.disabled = true;

  try {
    if (action === 'details') {
      showReleaseDetails(release);
    } else if (action === 'copy') {
      await copyText(release.download_url);
      setMessage('تم نسخ رابط التحميل.', 'success');
    } else if (action === 'download') {
      window.open(release.download_url, '_blank', 'noopener');
    } else if (action === 'activate') {
      await setReleaseActive(release.id, true);
    } else if (action === 'pause') {
      await setReleaseActive(release.id, false);
    } else if (action === 'campaign') {
      elements.campaignReleaseSelect.value = String(release.id);
      elements.campaignForm?.scrollIntoView({ behavior: 'smooth', block: 'start' });
      setMessage('تم اختيار الإصدار في نموذج الحملة. أكمل بيانات الحملة ثم احفظها.', 'success');
    } else if (action === 'delete') {
      await deleteRelease(release.id);
    }
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning');
  } finally {
    button.disabled = false;
  }
});

elements.showArchivedCampaignsInput.addEventListener('change', async (event) => {
  state.showArchivedCampaigns = Boolean(event.target.checked);
  try {
    await refreshData();
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning');
  }
});

elements.addCampaignRuleButton.addEventListener('click', () => {
  state.campaignRuleDrafts.push(createDefaultCampaignRule());
  renderCampaignRuleBuilder();
});

elements.cancelCampaignEditButton.addEventListener('click', () => {
  resetCampaignForm();
});

elements.campaignRuleList.addEventListener('input', (event) => {
  const target = event.target;
  const ruleId = target.getAttribute('data-rule-id');
  const field = target.getAttribute('data-rule-field');
  if (!ruleId || !field) {
    return;
  }

  const nextRules = state.campaignRuleDrafts.map((rule) => {
    if (rule.id !== ruleId) {
      return rule;
    }

    const nextRule = { ...rule };
    if (field === 'isExclude') {
      nextRule.isExclude = target.value === 'true';
    } else {
      nextRule[field] = target.value;
    }

    if (field === 'ruleType') {
      const definition = getRuleDefinition(target.value);
      nextRule.operator = definition.operatorLocked ? definition.operator : 'eq';
      nextRule.valueString = '';
      nextRule.valueJson = '';
      nextRule.groupId = '';
      nextRule.tagId = '';
    }

    if (field === 'operator' && target.value !== 'in') {
      nextRule.valueJson = '';
    }

    return normalizeRuleDraft(nextRule);
  });

  state.campaignRuleDrafts = nextRules;
  renderCampaignRuleBuilder();
});

elements.campaignRuleList.addEventListener('click', (event) => {
  const target = event.target;
  const action = target.getAttribute('data-rule-action');
  const ruleId = target.getAttribute('data-rule-id');
  if (action !== 'remove' || !ruleId) {
    return;
  }

  state.campaignRuleDrafts = state.campaignRuleDrafts.filter((rule) => rule.id !== ruleId);
  renderCampaignRuleBuilder();
});

elements.campaignsTable.addEventListener('click', async (event) => {
  const target = event.target;
  const action = target.getAttribute('data-campaign-action');
  const campaignId = Number(target.getAttribute('data-campaign-id'));

  if (!action || !campaignId) {
    return;
  }

  try {
    if (action === 'edit') {
      startCampaignEdit(campaignId);
      return;
    }

    if (action === 'inspect') {
      await loadCampaignDevices(campaignId);
      return;
    }

    if (action === 'archive') {
      if (!window.confirm('هل تريد أرشفة هذه الحملة؟ سيتم إخفاؤها من القائمة الافتراضية وتعطيلها.')) {
        return;
      }

      await archiveCampaign(campaignId);
      return;
    }

    if (action === 'delete') {
      if (!window.confirm('هل تريد حذف هذه الحملة نهائيًا؟ سيتم حذف سجلات حالة النشر الخاصة بها.')) {
        return;
      }

      await deleteCampaign(campaignId);
      return;
    }

    await toggleCampaignState(campaignId, action);
  } catch (error) {
    setMessage(parseErrorMessage(error), 'warning');
  }
});


resetCampaignForm();

initializeSession();