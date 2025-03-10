let defaultWebDicts = [
    WebDict(
        id: "daum_eng",
        name: "다음 영어사전",
        url: "https://dic.daum.net/top/search.do?dic=eng",
        script: daumScript,
        postScript: daumPostScript
    ),
    WebDict(
        id: "daum_ee",
        name: "다음 영영사전",
        url: "https://dic.daum.net/top/search.do?dic=ee",
        script: daumScript,
        postScript: daumPostScript
    ),
    
    WebDict(
        id: "daum_kor",
        name: "다음 국어사전",
        url: "https://dic.daum.net/top/search.do?dic=kor",
        script: daumScript,
        postScript: daumPostScript
    ),
    
    WebDict(
        id: "daum_jp",
        name: "다음 일본어사전",
        url: "https://dic.daum.net/top/search.do?dic=jp",
        script: daumScript,
        postScript: daumPostScript
    ),
    
    WebDict(
        id: "daum_ch",
        name: "다음 중국어사전",
        url: "https://dic.daum.net/top/search.do?dic=ch",
        script: daumScript,
        postScript: daumPostScript
    ),
    
    WebDict(
        id: "daum_hanja",
        name: "다음 한자사전",
        url: "https://dic.daum.net/top/search.do?dic=hanja",
        script: daumScript,
        postScript: daumPostScript
    ),
    WebDict(
        id: "naver_eng",
        name: "네이버 영어사전",
        url: "https://en.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    ),
    WebDict(
        id: "naver_ee",
        name: "네이버 영영사전",
        url: "https://english.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    ),
    
    WebDict(
        id: "naver_kor",
        name: "네이버 국어사전",
        url: "https://ko.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    ),
    
    WebDict(
        id: "naver_jp",
        name: "네이버 일본어사전",
        url: "https://ja.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    ),
    
    WebDict(
        id: "naver_ch",
        name: "네이버 중국어사전",
        url: "https://zh.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    ),
    
    WebDict(
        id: "naver_hanja",
        name: "네이버 한자사전",
        url: "https://hanja.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    ),
    WebDict(
        id: "deepl",
        name: "DeepL",
        url: "https://deepl.com",
        script: """
        let q = document.querySelector("d-textarea").firstChild;
        q.innerText = SD_clipboard_value;
        
        const inputEvent = new Event('input', {
            bubbles: true,
            cancelable: true
          });
        q.dispatchEvent(inputEvent); // 입력 이벤트 발생
        """
    ),
    WebDict(
        id: "chatgpt",
        name: "ChatGPT",
        url: "https://chatgpt.com",
        script: """
        document.querySelector(".ProseMirror").innerText = SD_clipboard_value;
        """,
        postScript: """
        setTimeout(() => {
            document.querySelector('[data-testid="send-button"]').click();
        }, 100);
        """
    ),
]

let daumScript = """
q.value = SD_clipboard_value;
q.select();
if(document.getElementById("searchBar") !== null) {
    searchBar.click();
}
const inputEvent = new Event('input', {
    bubbles: true,
    cancelable: true
  });
q.dispatchEvent(inputEvent); // 모바일 뷰에서 입력 이벤트 발생
"""

let daumPostScript = """
document.querySelector(".btn_search").click()
"""

let naverScript = """
var input = jQuery('#ac_input');
input[0].value = SD_clipboard_value;
input.focus();
"""

let naverPostScript = """
var btn = jQuery('#searchBtn')
btn.click()

document.querySelector(".btn_search").click() // PC판 검색 코드
"""
