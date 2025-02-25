let defaultWebDicts = [
    WebDict(
        id: "daum_eng",
        name: "다음 영어사전",
        url: "https://small.dic.daum.net/top/search.do?dic=eng",
        script: daumScript
    ),
    WebDict(
        id: "naver_eng",
        name: "네이버 영어사전",
        url: "https://en.dict.naver.com",
        script: naverScript
    ),
    WebDict(
        id: "deepl",
        name: "DeepL",
        url: "https://deepl.com",
        script: """
        document.querySelector("d-textarea").firstChild.innerText = SD_clipboard_value;
        """
    ),
    WebDict(
        id: "chatgpt",
        name: "ChatGPT",
        url: "https://chatgpt.com",
        script: """
        document.querySelector(".placeholder").innerText = SD_clipboard_value;
        """
    ),
]

let daumScript = """
q.value = SD_clipboard_value;
q.select();
if(document.getElementById("searchBar") !== null) {
    searchBar.click();
}
"""

let naverScript = """
var input = jQuery('#ac_input');
input[0].value = SD_clipboard_value;
input.focus();
"""
