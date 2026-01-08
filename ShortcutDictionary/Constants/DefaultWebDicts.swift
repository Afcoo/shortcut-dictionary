enum DefaultWebDicts {
    static let daum_eng = WebDict(
        id: "daum_eng",
        name: "다음 영어사전",
        url: "https://dic.daum.net/top/search.do?dic=eng",
        script: daumScript,
        postScript: daumPostScript
    )
    
    static let daum_ee = WebDict(
        id: "daum_ee",
        name: "다음 영영사전",
        url: "https://dic.daum.net/top/search.do?dic=ee",
        script: daumScript,
        postScript: daumPostScript
    )
    
    static let daum_kor = WebDict(
        id: "daum_kor",
        name: "다음 국어사전",
        url: "https://dic.daum.net/top/search.do?dic=kor",
        script: daumScript,
        postScript: daumPostScript
    )
    
    static let daum_jp = WebDict(
        id: "daum_jp",
        name: "다음 일본어사전",
        url: "https://dic.daum.net/top/search.do?dic=jp",
        script: daumScript,
        postScript: daumPostScript
    )
    
    static let daum_ch = WebDict(
        id: "daum_ch",
        name: "다음 중국어사전",
        url: "https://dic.daum.net/top/search.do?dic=ch",
        script: daumScript,
        postScript: daumPostScript
    )
    
    static let daum_hanja = WebDict(
        id: "daum_hanja",
        name: "다음 한자사전",
        url: "https://dic.daum.net/top/search.do?dic=hanja",
        script: daumScript,
        postScript: daumPostScript
    )
    
    static let naver_eng = WebDict(
        id: "naver_eng",
        name: "네이버 영어사전",
        url: "https://en.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    )
    
    static let naver_ee = WebDict(
        id: "naver_ee",
        name: "네이버 영영사전",
        url: "https://english.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    )
    
    static let naver_kor = WebDict(
        id: "naver_kor",
        name: "네이버 국어사전",
        url: "https://ko.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    )
    
    static let naver_jp = WebDict(
        id: "naver_jp",
        name: "네이버 일본어사전",
        url: "https://ja.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    )
    
    static let naver_ch = WebDict(
        id: "naver_ch",
        name: "네이버 중국어사전",
        url: "https://zh.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    )
    
    static let naver_hanja = WebDict(
        id: "naver_hanja",
        name: "네이버 한자사전",
        url: "https://hanja.dict.naver.com",
        script: naverScript,
        postScript: naverPostScript
    )
    
    static let deepl = WebDict(
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
    )
    
    static let google_translate = WebDict(
        id: "google_translate",
        name: "Google 번역",
        url: "https://translate.google.com",
        script: """
        let q = document.querySelector("textarea");
        q.innerText = SD_clipboard_value;
        
        const inputEvent = new Event('input', {
            bubbles: true,
            cancelable: true
        });
        q.dispatchEvent(inputEvent); // 입력 이벤트 발생
        """
    )
    
    static let chatgpt = WebDict(
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
    )
    
    static let claude = WebDict(
        id: "claude",
        name: "Claude",
        url: "https://claude.ai/",
        script: """
        document.querySelector(".ProseMirror").innerText = SD_clipboard_value;
        """,
        postScript: """
        setTimeout(() => {
            const q = document.querySelector(".ProseMirror")
            const enterEvent = new KeyboardEvent('keydown', { 
                key: 'Enter',
                code: 'Enter',
                keyCode: 13,
                which: 13,
                bubbles: true,
                cancelable: true,
                metaKey: true
            }); // cmd + enter 단축키 전송
            
            q.dispatchEvent(enterEvent);
        }, 100);
        """
    )
    
    static let gemini = WebDict(
        id: "gemini",
        name: "Gemini",
        url: "https://gemini.google.com/",
        script: """
        document.querySelector(".ql-editor").innerText = SD_clipboard_value;
        """,
        postScript: """
        setTimeout(() => {
            document.querySelector(".send-button").click();
        }, 100);
        """
    )
}

// 전체 목록
extension DefaultWebDicts {
    static let daum_all = WebDict(
        id: "daum_all", name: "다음 사전", url: "", script: "", isEmptyParent: true,
        children: [daum_eng, daum_ee, daum_kor, daum_jp, daum_ch, daum_hanja]
    )
    
    static let naver_all = WebDict(
        id: "naver_all", name: "네이버 사전", url: "", script: "", isEmptyParent: true,
        children: [naver_eng, naver_ee, naver_kor, naver_jp, naver_ch, naver_hanja]
    )
    
    static let all = [
        daum_all, naver_all,
        
        // 번역기
        deepl, google_translate,
        
        // LLM
        chatgpt, claude, gemini
    ]
}

extension DefaultWebDicts {
    static let daumScript = """
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

    static let daumPostScript = """
    document.querySelector(".btn_search").click()
    """

    static let naverScript = """
    var input = jQuery('#ac_input');
    input[0].value = SD_clipboard_value;
    input.focus();
    """

    static let naverPostScript = """
    var btn = jQuery('#searchBtn')
    btn.click()
    
    document.querySelector(".btn_search").click() // PC판 검색 코드
    """
}
