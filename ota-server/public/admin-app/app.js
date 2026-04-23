const API_BASE = '/api';

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
};

const CAMPAIGN_RULE_TYPES = [
  { value: 'group', label: 'Group', operatorLocked: true, operator: 'eq', valueMode: 'group' },
  { value: 'tag', label: 'Tag', operatorLocked: true, operator: 'eq', valueMode: 'tag' },
  { value: 'current_version', label: 'Current Version', valueMode: 'string' },
  { value: 'model', label: 'Model', valueMode: 'string' },
  { value: 'board', label: 'Board', valueMode: 'string' },
  { value: 'mac', label: 'MAC', valueMode: 'string' },
  { value: 'token', label: 'Token', valueMode: 'string' },
];

const CAMPAIGN_OPERATORS = [
  { value: 'eq', label: 'Equals' },
  { value: 'neq', label: 'Not Equals' },
  { value: 'contains', label: 'Contains' },
  { value: 'prefix', label: 'Starts With' },
  { value: 'in', label: 'In List' },
];

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
  return Number.isNaN(date.getTime()) ? '-' : date.toLocaleString();
}

function truncateText(value, limit = 140) {
  const text = String(value ?? '');
  return text.length > limit ? `${text.slice(0, limit - 1)}…` : text;
}

function renderPills(items, mapper) {
  if (!items || items.length === 0) {
    return '<span class="pill warning">None</span>';
  }

  return `<div class="pill-row">${items.map((item) => `<span class="pill">${escapeHtml(mapper(item))}</span>`).join('')}</div>`;
}

function parseErrorMessage(error) {
  try {
    const parsed = JSON.parse(error.message);
    if (typeof parsed.message === 'string') {
      return parsed.message;
    }

    if (Array.isArray(parsed.message)) {
      return parsed.message.join(', ');
    }
  } catch {
    return error.message;
  }

  return error.message;
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
  const scopeLabel = rule.isExclude ? 'Exclude' : 'Include';

  if (definition.valueMode === 'group') {
    const group = state.groups.find((item) => String(item.id) === String(rule.groupId));
    return `${scopeLabel} group:${group?.name ?? 'unselected'}`;
  }

  if (definition.valueMode === 'tag') {
    const tag = state.tags.find((item) => String(item.id) === String(rule.tagId));
    return `${scopeLabel} tag:${tag?.name ?? 'unselected'}`;
  }

  if (rule.operator === 'in') {
    return `${scopeLabel} ${definition.label.toLowerCase()} in ${rule.valueJson || '[]'}`;
  }

  return `${scopeLabel} ${definition.label.toLowerCase()} ${rule.operator} ${rule.valueString || '...'}`;
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
  elements.campaignFormTitle.textContent = 'Create Campaign';
  elements.campaignSubmitButton.textContent = 'Create Campaign';
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
  elements.campaignFormTitle.textContent = `Edit Campaign #${campaign.id}`;
  elements.campaignSubmitButton.textContent = 'Update Campaign';
  elements.cancelCampaignEditButton.hidden = false;
  renderCampaignRuleBuilder();
  forms.campaign.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function renderCampaignRuleBuilder() {
  if (state.campaignRuleDrafts.length === 0) {
    elements.campaignRuleList.innerHTML = '<div class="empty-state">No rules yet. This campaign will match all devices for the selected release model.</div>';
    elements.campaignRulesPreview.innerHTML = '<span class="pill subtle">All devices in selected release scope</span>';
    return;
  }

  const groupOptions = [{ value: '', label: 'Select group…' }, ...state.groups.map((group) => ({
    value: group.id,
    label: `${group.name} (#${group.id})`,
  }))];
  const tagOptions = [{ value: '', label: 'Select tag…' }, ...state.tags.map((tag) => ({
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
          <span>Group</span>
          <select data-rule-field="groupId" data-rule-id="${escapeHtml(rule.id)}">${optionMarkup(groupOptions, rule.groupId)}</select>
        </label>
      `;
    } else if (definition.valueMode === 'tag') {
      valueControl = `
        <label>
          <span>Tag</span>
          <select data-rule-field="tagId" data-rule-id="${escapeHtml(rule.id)}">${optionMarkup(tagOptions, rule.tagId)}</select>
        </label>
      `;
    } else if (rule.operator === 'in') {
      valueControl = `
        <label>
          <span>Comma-separated values</span>
          <input data-rule-field="valueJson" data-rule-id="${escapeHtml(rule.id)}" value="${escapeHtml(rule.valueJson)}" placeholder="v1,v2,v3">
        </label>
      `;
    } else {
      valueControl = `
        <label>
          <span>Value</span>
          <input data-rule-field="valueString" data-rule-id="${escapeHtml(rule.id)}" value="${escapeHtml(rule.valueString)}" placeholder="Enter match value">
        </label>
      `;
    }

    return `
      <div class="rule-builder-row">
        <label>
          <span>Scope</span>
          <select data-rule-field="isExclude" data-rule-id="${escapeHtml(rule.id)}">
            <option value="false"${rule.isExclude ? '' : ' selected'}>Include</option>
            <option value="true"${rule.isExclude ? ' selected' : ''}>Exclude</option>
          </select>
        </label>
        <label>
          <span>Rule Type</span>
          <select data-rule-field="ruleType" data-rule-id="${escapeHtml(rule.id)}">${optionMarkup(CAMPAIGN_RULE_TYPES.map((item) => ({ value: item.value, label: item.label })), rule.ruleType)}</select>
        </label>
        <label>
          <span>Operator</span>
          <select data-rule-field="operator" data-rule-id="${escapeHtml(rule.id)}"${definition.operatorLocked ? ' disabled' : ''}>${operatorOptions}</select>
        </label>
        ${valueControl}
        <div></div>
        <button class="secondary-button" type="button" data-rule-action="remove" data-rule-id="${escapeHtml(rule.id)}">Remove</button>
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
    return '<div class="empty-state">No records yet.</div>';
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

  if (options.body && !headers.has('Content-Type')) {
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
    const text = await response.text();
    throw new Error(text || `Request failed with ${response.status}`);
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
  elements.sessionBadge.textContent = signedIn && state.admin
    ? `${state.admin.email} • ${state.admin.role}`
    : 'Not signed in';
  elements.sessionBadge.classList.toggle('muted', !signedIn);
}

function collectFormData(form) {
  const formData = new FormData(form);
  return Object.fromEntries(formData.entries());
}

function hydrateSelect(selectElement, items, mapper, includeEmpty = true) {
  const currentValue = selectElement.value;
  const options = [];

  if (includeEmpty) {
    options.push('<option value="">Select…</option>');
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
    { label: 'Total Devices', value: counts.total_devices, note: 'All registered routers' },
    { label: 'Seen in 24h', value: counts.online_last_24h, note: 'Recently active devices' },
    { label: 'Active Campaigns', value: counts.active_campaigns, note: 'Rollouts in progress' },
    { label: 'Firmware Models', value: counts.firmware_models, note: 'Managed device types' },
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
      <td>
        <strong>${escapeHtml(device.firmware_model?.display_name ?? device.model)}</strong><br>
        <span class="mono">${escapeHtml(device.model)}</span>
      </td>
      <td class="mono">${escapeHtml(device.current_version ?? '-')}</td>
      <td>${escapeHtml(device.status ?? '-')}</td>
      <td>${formatDate(device.last_seen_at)}</td>
      <td>${renderPills(device.groups, (group) => group.name)}</td>
      <td>${renderPills(device.tags, (tag) => tag.name)}</td>
      <td>${escapeHtml(device.last_error ?? '-')}</td>
    </tr>
  `);

  elements.devicesTable.innerHTML = tableMarkup(
    ['ID', 'Device', 'Version', 'Status', 'Last Seen', 'Groups', 'Tags', 'Last Error'],
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
    ['ID', 'Display Name', 'Model Key', 'Board', 'Devices', 'Releases'],
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

  elements.groupsTable.innerHTML = tableMarkup(['ID', 'Group', 'Members'], rows);
}

function renderTags() {
  const rows = state.tags.map((tag) => `
    <tr>
      <td class="mono">${escapeHtml(tag.id)}</td>
      <td>${escapeHtml(tag.name)}</td>
      <td>${escapeHtml(tag.member_count)}</td>
    </tr>
  `);

  elements.tagsTable.innerHTML = tableMarkup(['ID', 'Tag', 'Members'], rows);
}

function renderReleases() {
  const rows = filterReleases().map((release) => `
    <tr>
      <td class="mono">${escapeHtml(release.id)}</td>
      <td>${escapeHtml(release.version)}</td>
      <td>
        <strong>${escapeHtml(release.firmware_model?.display_name ?? release.model)}</strong><br>
        <span class="mono">${escapeHtml(release.model)}</span>
      </td>
      <td>${escapeHtml(release.channel)}</td>
      <td>${release.active ? '<span class="pill">Active</span>' : '<span class="pill warning">Inactive</span>'}</td>
      <td class="mono">${escapeHtml(release.sha256.slice(0, 12))}…</td>
    </tr>
  `);

  elements.releasesTable.innerHTML = tableMarkup(
    ['ID', 'Version', 'Firmware Model', 'Channel', 'State', 'SHA256'],
    rows,
  );
}

function renderCampaigns() {
  const rows = state.campaigns.map((campaign) => {
    const stateMarkup = campaign.archived_at
      ? '<span class="pill subtle">Archived</span>'
      : (campaign.active ? '<span class="pill">Live</span>' : '<span class="pill warning">Paused</span>');
    const actionButtons = [];

    if (!campaign.archived_at) {
      actionButtons.push(`<button class="table-action-button" type="button" data-campaign-action="edit" data-campaign-id="${escapeHtml(campaign.id)}">Edit</button>`);
    }

    actionButtons.push(`<button class="table-action-button active" type="button" data-campaign-action="inspect" data-campaign-id="${escapeHtml(campaign.id)}">Inspect</button>`);

    if (!campaign.archived_at) {
      actionButtons.push(`<button class="table-action-button" type="button" data-campaign-action="${campaign.active ? 'pause' : 'activate'}" data-campaign-id="${escapeHtml(campaign.id)}">${campaign.active ? 'Pause' : 'Activate'}</button>`);
      actionButtons.push(`<button class="table-action-button" type="button" data-campaign-action="archive" data-campaign-id="${escapeHtml(campaign.id)}">Archive</button>`);
    }

    actionButtons.push(`<button class="table-action-button" type="button" data-campaign-action="delete" data-campaign-id="${escapeHtml(campaign.id)}">Delete</button>`);

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
          const suffix = rule.group?.name ?? rule.tag?.name ?? rule.value_string ?? rule.operator;
          return `${rule.rule_type}:${suffix}`;
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
    ['ID', 'Campaign', 'Firmware Model', 'Priority', 'Rollout', 'State', 'Rules', 'Actions'],
    rows,
  );
}

function renderCampaignDevices() {
  const selectedCampaign = state.campaigns.find((campaign) => campaign.id === state.selectedCampaignId);

  if (!state.selectedCampaignId || !selectedCampaign) {
    elements.campaignDetailsPanel.hidden = true;
    elements.campaignDevicesTable.innerHTML = '';
    elements.campaignDetailsTitle.textContent = 'Campaign devices';
    elements.campaignDetailsMeta.textContent = 'Select a campaign to inspect its tracked devices.';
    return;
  }

  elements.campaignDetailsPanel.hidden = false;
  elements.campaignDetailsTitle.textContent = `${selectedCampaign.name} device states`;
  elements.campaignDetailsMeta.textContent = selectedCampaign
    ? `${selectedCampaign.release.version} • ${state.campaignDevices.length} tracked devices`
    : `${state.campaignDevices.length} tracked devices`;

  const rows = state.campaignDevices.map((entry) => `
    <tr>
      <td class="mono">${escapeHtml(entry.device.id)}</td>
      <td>
        <strong>${escapeHtml(entry.device.firmware_model?.display_name ?? entry.device.model)}</strong><br>
        <span class="mono">${escapeHtml(entry.device.mac)}</span>
      </td>
      <td>${escapeHtml(entry.eligibility_status)}</td>
      <td>${escapeHtml(entry.update_status ?? '-')}</td>
      <td>${formatDate(entry.matched_at)}</td>
      <td>${formatDate(entry.delivered_at)}</td>
      <td>${formatDate(entry.last_evaluated_at)}</td>
    </tr>
  `);

  elements.campaignDevicesTable.innerHTML = tableMarkup(
    ['Device ID', 'Device', 'Eligibility', 'Update Status', 'Matched At', 'Delivered At', 'Last Evaluated'],
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
      <td>${escapeHtml(log.admin_user?.email ?? 'system')}</td>
      <td class="audit-payload">${escapeHtml(truncateText(JSON.stringify(log.payload_json ?? {}), 220))}</td>
      <td>${formatDate(log.created_at)}</td>
    </tr>
  `);

  elements.auditLogsTable.innerHTML = tableMarkup(
    ['ID', 'Action', 'Entity', 'Entity ID', 'Actor', 'Payload', 'Created At'],
    rows,
  );
}

function refreshSelectors() {
  hydrateSelect(elements.releaseModelSelect, state.models, (model) => ({
    value: model.id,
    label: `${model.display_name} • ${model.model_key}`,
  }));

  hydrateSelect(elements.releaseFilterSelect, state.models, (model) => ({
    value: model.id,
    label: `${model.display_name} • ${model.model_key}`,
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
  setMessage('Loading campaign devices…');

  try {
    state.campaignDevices = await apiFetch(`/admin/campaigns/${campaignId}/devices`);
    renderCampaignDevices();
    setMessage('Campaign device states loaded.');
  } catch (error) {
    state.campaignDevices = [];
    renderCampaignDevices();
    setMessage(parseErrorMessage(error), 'warning');
  }
}

async function toggleCampaignState(campaignId, action) {
  const path = action === 'pause' ? 'pause' : 'activate';
  setMessage(action === 'pause' ? 'Pausing campaign…' : 'Activating campaign…');
  await apiFetch(`/admin/campaigns/${campaignId}/${path}`, { method: 'POST' });
  await refreshData();
  if (state.selectedCampaignId === campaignId) {
    await loadCampaignDevices(campaignId);
  }
}

async function archiveCampaign(campaignId) {
  setMessage('Archiving campaign…');
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
  setMessage('Deleting campaign…');
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
  setMessage('Refreshing dashboard data…');

  const campaignPath = state.showArchivedCampaigns ? '/admin/campaigns?include_archived=true' : '/admin/campaigns';
  const [summary, devices, models, groups, tags, releases, campaigns, auditLogs] = await Promise.all([
    apiFetch('/admin/dashboard'),
    apiFetch('/admin/devices'),
    apiFetch('/admin/models'),
    apiFetch('/admin/groups'),
    apiFetch('/admin/tags'),
    apiFetch('/admin/releases'),
    apiFetch(campaignPath),
    apiFetch('/admin/audit-logs?limit=50'),
  ]);

  state.summary = summary;
  state.devices = devices;
  state.models = models;
  state.groups = groups;
  state.tags = tags;
  state.releases = releases;
  state.campaigns = campaigns;
  state.auditLogs = auditLogs;
  if (!state.campaigns.some((campaign) => campaign.id === state.selectedCampaignId)) {
    state.selectedCampaignId = null;
    state.campaignDevices = [];
  }
  if (state.editingCampaignId != null && !state.campaigns.some((campaign) => campaign.id === state.editingCampaignId)) {
    resetCampaignForm();
  }
  renderAll();
  setMessage('Dashboard synchronized.');
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
    setMessage(error.message, 'warning', elements.loginMessage);
  }
}

elements.loginForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setMessage('Signing in…', 'muted', elements.loginMessage);

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
    setMessage('Authenticated.', 'muted', elements.loginMessage);
    await refreshData();
  } catch (error) {
    setMessage(error.message, 'warning', elements.loginMessage);
  }
});

elements.refreshButton.addEventListener('click', async () => {
  try {
    await refreshData();
  } catch (error) {
    setMessage(error.message, 'warning');
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
    setMessage('Signed out.', 'muted', elements.loginMessage);
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
    setMessage(error.message, 'warning');
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
    setMessage(error.message, 'warning');
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
    setMessage(error.message, 'warning');
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
    setMessage(error.message, 'warning');
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
    setMessage(error.message, 'warning');
  }
});

forms.release.addEventListener('submit', async (event) => {
  event.preventDefault();
  try {
    const data = collectFormData(forms.release);
    const payload = {
      firmware_model_id: data.firmware_model_id ? Number(data.firmware_model_id) : undefined,
      model: data.model || undefined,
      version: data.version,
      version_code: data.version_code || undefined,
      artifact_path: data.artifact_path,
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
    forms.release.reset();
    await refreshData();
  } catch (error) {
    setMessage(error.message, 'warning');
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
        throw new Error('Group and tag rules require a selected value.');
      }

      if (rule.rule_type !== 'group' && rule.rule_type !== 'tag' && rule.operator !== 'in' && !rule.value_string) {
        throw new Error(`Rule ${rule.rule_type} requires a value.`);
      }

      if (rule.operator === 'in' && (!Array.isArray(rule.value_json) || rule.value_json.length === 0)) {
        throw new Error(`Rule ${rule.rule_type} requires at least one list value.`);
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

elements.releaseFilterSelect.addEventListener('change', (event) => {
  state.releaseFilterModelId = event.target.value;
  renderReleases();
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
      if (!window.confirm('Archive this campaign? It will be hidden from the default list and deactivated.')) {
        return;
      }

      await archiveCampaign(campaignId);
      return;
    }

    if (action === 'delete') {
      if (!window.confirm('Delete this campaign permanently? This will remove its rollout state records.')) {
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