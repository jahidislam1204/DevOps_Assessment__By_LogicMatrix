/* ==========================================
   API CONFIGURATION
========================================== */

const API_URL =
    window.location.hostname === "localhost"
        ? "http://localhost:8080"
        : window.location.origin;


/* ==========================================
   DOM ELEMENTS
========================================== */

const noteInput = document.getElementById("noteInput");

const saveBtn = document.getElementById("saveBtn");

const notesContainer = document.getElementById("notesContainer");

const emptyState = document.getElementById("emptyState");

const toast = document.getElementById("toast");

const charCount = document.getElementById("charCount");

const searchInput = document.getElementById("searchInput");

const sortSelect = document.getElementById("sortSelect");

const newBtn = document.querySelector(".new-btn");


/* ==========================================
   APPLICATION STATE
========================================== */

let notes = [];

let filteredNotes = [];


/* ==========================================
   INITIALIZE APPLICATION
========================================== */

window.addEventListener("DOMContentLoaded", () => {

    updateCharacterCounter();

    loadNotes();

});


/* ==========================================
   CHARACTER COUNTER
========================================== */

function updateCharacterCounter() {

    charCount.innerText =
        `${noteInput.value.length} / 500`;

}


noteInput.addEventListener("input", updateCharacterCounter);


/* ==========================================
   TOAST NOTIFICATION
========================================== */

function showToast(message) {

    toast.innerText = message;

    toast.classList.add("show");

    setTimeout(() => {

        toast.classList.remove("show");

    }, 2500);

}


/* ==========================================
   SAVE NOTE
========================================== */

saveBtn.addEventListener("click", saveNote);

async function saveNote() {

    const text = noteInput.value.trim();

    if (text === "") {

        showToast("Please write something.");

        noteInput.focus();

        return;

    }

    try {

        const response = await fetch(`${API_URL}/notes`, {

            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                text: text
            })

        });

        if (!response.ok) {

            throw new Error("Failed to save note.");

        }

        noteInput.value = "";

        updateCharacterCounter();

        showToast("Note saved successfully.");

        loadNotes();

    }

    catch (error) {

        console.error(error);

        showToast("Unable to connect to backend.");

    }

}


/* ==========================================
   NEW NOTE BUTTON
========================================== */

newBtn.addEventListener("click", () => {

    noteInput.value = "";

    updateCharacterCounter();

    noteInput.focus();

});


/* ==========================================
   SEARCH NOTES
========================================== */

searchInput.addEventListener("input", () => {

    const keyword = searchInput.value.toLowerCase();

    filteredNotes = notes.filter(note =>

        note.text.toLowerCase().includes(keyword)

    );

    renderNotes(filteredNotes);

});


/* ==========================================
   SORT NOTES
========================================== */

sortSelect.addEventListener("change", () => {

    if (sortSelect.selectedIndex === 0) {

        filteredNotes.reverse();

    }

    else {

        filteredNotes.reverse();

    }

    renderNotes(filteredNotes);

});



/* ==========================================
   LOAD NOTES FROM BACKEND
========================================== */

async function loadNotes() {

    try {

        const response = await fetch(`${API_URL}/notes`);

        if (!response.ok) {

            throw new Error("Failed to load notes.");

        }

        notes = await response.json();

        // Add createdAt if backend doesn't provide one
        notes = notes.map(note => ({

            ...note,

            createdAt: note.createdAt || new Date().toISOString()

        }));

        filteredNotes = [...notes];

        renderNotes(filteredNotes);

    }

    catch (error) {

        console.error(error);

        showToast("Unable to load notes.");

    }

}


/* ==========================================
   RENDER NOTES
========================================== */

function renderNotes(noteList) {

    notesContainer.innerHTML = "";

    if (noteList.length === 0) {

        notesContainer.style.display = "none";

        emptyState.style.display = "flex";

        return;

    }

    notesContainer.style.display = "grid";

    emptyState.style.display = "none";

    noteList.forEach(note => {

        const card = document.createElement("div");

        card.className = "note-card";

        card.innerHTML = `

            <div class="note-text">

                ${escapeHTML(note.text)}

            </div>

            <div class="note-footer">

                <span class="note-date">

                    ${formatDate(note.createdAt)}

                </span>

                <button
                    class="delete-btn"
                    onclick="deleteNote(${note.id})">

                    <i class="fa-solid fa-trash"></i>

                </button>

            </div>

        `;

        notesContainer.appendChild(card);

    });

}


/* ==========================================
   DELETE NOTE
========================================== */

function deleteNote(id) {

    notes = notes.filter(note => note.id !== id);

    filteredNotes = [...notes];

    renderNotes(filteredNotes);

    showToast("Note removed.");

}


/* ==========================================
   FORMAT DATE
========================================== */

function formatDate(dateString) {

    const date = new Date(dateString);

    return date.toLocaleString("en-US", {

        day: "2-digit",

        month: "short",

        year: "numeric",

        hour: "2-digit",

        minute: "2-digit"

    });

}


/* ==========================================
   ESCAPE HTML
========================================== */

function escapeHTML(text) {

    const div = document.createElement("div");

    div.innerText = text;

    return div.innerHTML;

}


/* ==========================================
   REFRESH NOTES
========================================== */

function refreshNotes() {

    filteredNotes = [...notes];

    renderNotes(filteredNotes);

}


/* ==========================================
   CLEAR SEARCH
========================================== */

function clearSearch() {

    searchInput.value = "";

    refreshNotes();

}



/* ==========================================
   SORT NOTES
========================================== */

sortSelect.addEventListener("change", sortNotes);

function sortNotes() {

    const selected = sortSelect.value;

    if (selected === "Newest First") {

        filteredNotes.sort((a, b) => b.id - a.id);

    } else {

        filteredNotes.sort((a, b) => a.id - b.id);

    }

    renderNotes(filteredNotes);

}


/* ==========================================
   SEARCH NOTES
========================================== */

searchInput.addEventListener("keyup", () => {

    const keyword = searchInput.value
        .trim()
        .toLowerCase();

    if (keyword === "") {

        filteredNotes = [...notes];

    } else {

        filteredNotes = notes.filter(note =>

            note.text
                .toLowerCase()
                .includes(keyword)

        );

    }

    sortNotes();

});


/* ==========================================
   KEYBOARD SHORTCUT
========================================== */

noteInput.addEventListener("keydown", (event) => {

    if (event.ctrlKey && event.key === "Enter") {

        event.preventDefault();

        saveNote();

    }

});


/* ==========================================
   AUTO FOCUS
========================================== */

window.addEventListener("load", () => {

    noteInput.focus();

});


/* ==========================================
   LOADING STATE
========================================== */

function setLoading(isLoading) {

    if (isLoading) {

        saveBtn.disabled = true;

        saveBtn.innerHTML = `

            <i class="fa-solid fa-spinner fa-spin"></i>

            Saving...

        `;

    }

    else {

        saveBtn.disabled = false;

        saveBtn.innerHTML = `

            <i class="fa-solid fa-floppy-disk"></i>

            Save Note

        `;

    }

}


/* ==========================================
   OVERRIDE SAVE FUNCTION
========================================== */

const originalSaveNote = saveNote;

saveNote = async function () {

    const text = noteInput.value.trim();

    if (text === "") {

        showToast("Please write a note.");

        noteInput.focus();

        return;

    }

    try {

        setLoading(true);

        const response = await fetch(`${API_URL}/notes`, {

            method: "POST",

            headers: {

                "Content-Type": "application/json"

            },

            body: JSON.stringify({

                text: text

            })

        });

        if (!response.ok) {

            throw new Error();

        }

        noteInput.value = "";

        updateCharacterCounter();

        await loadNotes();

        showToast("Note saved successfully.");

    }

    catch (error) {

        console.error(error);

        showToast("Backend connection failed.");

    }

    finally {

        setLoading(false);

    }

};


/* ==========================================
   WINDOW ONLINE/OFFLINE
========================================== */

window.addEventListener("offline", () => {

    showToast("No internet connection.");

});

window.addEventListener("online", () => {

    showToast("Connection restored.");

});


/* ==========================================
   INITIAL SORT
========================================== */

window.addEventListener("DOMContentLoaded", () => {

    sortNotes();

});


/* ==========================================
   DEVELOPER MESSAGE
========================================== */

console.log(

    "%cProfessional Note App Loaded Successfully",

    "color:white;" +

    "background:#6366F1;" +

    "padding:10px;" +

    "font-size:14px;" +

    "border-radius:6px;"

);



/* ==========================================
   TRASH BUTTON
========================================== */

const trashBtn = document.getElementById("trashBtn");

trashBtn.addEventListener("click", () => {

    showToast("Trash feature will be available soon.");

});



/* ==========================================
   ABOUT BUTTON
========================================== */

const aboutBtn = document.getElementById("aboutBtn");

aboutBtn.addEventListener("click", () => {

    alert(`
NoteApp

Version : 1.0

Developer : Jahid Islam

Frontend :
HTML
CSS
JavaScript

Backend :
Python Flask

Future:
AWS RDS
Docker
CI/CD
`);

});


/* ==========================================
   LIGHT / DARK MODE
========================================== */

const themeBtn = document.getElementById("themeBtn");

let darkMode = false;

themeBtn.addEventListener("click", () => {

    darkMode = !darkMode;

    if (darkMode) {

        document.body.classList.add("dark");

        themeBtn.innerHTML = `
            <i class="fa-solid fa-moon"></i>
            Dark Theme
        `;

    }

    else {

        document.body.classList.remove("dark");

        themeBtn.innerHTML = `
            <i class="fa-solid fa-sun"></i>
            Light Theme
        `;

    }

});
