/* ============================================================
   ui/app.js
   ลำดับในไฟล์นี้:
   1. State    — ข้อมูล runtime ฝั่ง JS
   2. Render   — function วาด UI จาก State
   3. NUI      — คุยกับ Lua (postMessage / window.addEventListener)
   4. Events   — ผูก DOM events (click, input)
   5. Init     — รันตอนหน้าเว็บโหลด
   ============================================================ */

'use strict';

/* ── 1. STATE ────────────────────────────────────────────── */

const State = {
    value: 0,
};

/* ── 2. RENDER ───────────────────────────────────────────── */
// function เหล่านี้อ่าน State แล้ววาด DOM
// ไม่มี logic อื่นปนอยู่

function render() {
    document.getElementById('display-value').textContent = State.value;
}

function showUI() {
    document.getElementById('app').classList.remove('hidden');
}

function hideUI() {
    document.getElementById('app').classList.add('hidden');
}

/* ── 3. NUI BRIDGE ───────────────────────────────────────── */

// ── รับข้อมูลจาก Lua ─────────────────────────────────────
window.addEventListener('message', ({ data }) => {
    switch (data.action) {

        case 'open':
            // Lua ส่งข้อมูลมาพร้อมกับ open
            if (data.data) updateState(data.data);
            showUI();
            break;

        case 'update':
            // Lua ส่งอัปเดตขณะ UI เปิดอยู่
            if (data.data) updateState(data.data);
            break;

        case 'close':
            hideUI();
            break;
    }
});

function updateState(payload) {
    if (payload.value !== undefined) State.value = payload.value;
    render();
}

// ── ส่งข้อมูลไปหา Lua ────────────────────────────────────
function nuiPost(endpoint, data = {}) {
    return fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(data),
    }).catch(() => {
        // ถ้า fetch ล้มเหลว (dev mode ในเบราว์เซอร์) ให้ไม่ crash
        console.warn('[NUI] fetch failed — running outside FiveM?');
    });
}

// ── GetParentResourceName fallback สำหรับ dev ───────────
function GetParentResourceName() {
    return window.GetParentResourceName?.() ?? 'mg_template_ui';
}

/* ── 4. DOM EVENTS ───────────────────────────────────────── */

document.getElementById('btn-close').addEventListener('click', () => {
    nuiPost('close');
    hideUI();
});

document.getElementById('btn-action').addEventListener('click', () => {
    nuiPost('doAction', { amount: 10 });
});

// ESC ปิด UI
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        nuiPost('close');
        hideUI();
    }
});

/* ── 5. INIT ─────────────────────────────────────────────── */
// ซ่อน UI ตอนแรก รอ Lua สั่ง open
hideUI();
