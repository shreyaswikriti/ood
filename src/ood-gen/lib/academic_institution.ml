type location = { lat : float; long : float } [@@deriving yaml]

type course = {
  name : string;
  acronym : string option;
  online_resource : string option;
}
[@@deriving yaml]

type metadata = {
  name : string;
  description : string;
  url : string;
  logo : string option;
  continent : string;
  courses : course list;
  location : location option;
}
[@@deriving yaml]

type t = {
  name : string;
  description : string;
  url : string;
  logo : string option;
  continent : string;
  courses : course list;
  location : location option;
  body_md : string;
  body_html : string;
}

let all () =
  Utils.map_files
    (fun content ->
      let metadata, body = Utils.extract_metadata_body content in
      let metadata = Utils.decode_or_raise metadata_of_yaml metadata in
      {
        name = metadata.name;
        description = metadata.description;
        url = metadata.url;
        logo = metadata.logo;
        continent = metadata.continent;
        courses = metadata.courses;
        location = metadata.location;
        body_md = body;
        body_html = Omd.of_string body |> Omd.to_html;
      })
    "academic_institutions/en"

let pp_course ppf (v : course) =
  Fmt.pf ppf
    {|
  {
    name = %S;
    acronym = %a;
    online_resource  = %a;
  }|}
    v.name
    (Pp.option Pp.quoted_string)
    v.acronym
    (Pp.option Pp.quoted_string)
    v.online_resource

let pp_location ppf v =
  Fmt.pf ppf {|
  {
    long = %f;
    lat = %f;
  }
  |} v.long v.lat

let pp ppf v =
  Fmt.pf ppf
    {|
  { 
    name = %S;
    description = %S;
    url = %S;
    logo = %a;
    continent = %S;
    courses = %a;
    location = %a;
    body_md = %S;
    body_html = %S;
  }|}
    v.name v.description v.url
    (Pp.option Pp.quoted_string)
    v.logo v.continent (Pp.list pp_course) v.courses (Pp.option pp_location)
    v.location v.body_md v.body_html

let pp_list = Pp.list pp

let template =
  Format.asprintf
    {|
type location = { lat : float; long : float }

type course = {
  name : string;
  acronym : string option;
  online_resource : string option;
}

type t = {
  name : string;
  description : string;
  url : string;
  logo : string option;
  continent : string;
  courses : course list;
  location : location option;
  body_md : string;
  body_html : string;
}

let all = %a
|}
    pp_list (all ())