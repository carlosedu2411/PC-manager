export namespace media {
	
	export class MediaInfo {
	    title: string;
	    artist: string;
	    album: string;
	    cover: string;
	    playing: boolean;
	
	    static createFrom(source: any = {}) {
	        return new MediaInfo(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.title = source["title"];
	        this.artist = source["artist"];
	        this.album = source["album"];
	        this.cover = source["cover"];
	        this.playing = source["playing"];
	    }
	}

}

export namespace shortcuts {
	
	export class Shortcut {
	    id: number;
	    name: string;
	    icon: string;
	    command: string;
	
	    static createFrom(source: any = {}) {
	        return new Shortcut(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.id = source["id"];
	        this.name = source["name"];
	        this.icon = source["icon"];
	        this.command = source["command"];
	    }
	}

}

