import json
import re
import requests

from_cmdline = False
try:
    __file__
    from_cmdline = True
except NameError:
    pass

if not from_cmdline:
    import vim


METHOD_REGEX = re.compile('^(GET|POST|DELETE|PUT|HEAD|OPTIONS|PATCH) (.*)$')
HEADER_REGEX = re.compile('^([^()<>@,;:\<>/\[\]?={}]+):\\s*(.*)$')
VAR_REGEX = re.compile('^# ?(:[^: ]+)\\s*=\\s*(.+)$')
GLOBAL_VAR_REGEX = re.compile('^# ?(\$[^$ ]+)\\s*=\\s*(.+)$')
FILE_REGEX = re.compile("!((?:file)|(?:(?:content)))\((.+)\)")


def replace_vars(string, variables):
    for var, val in variables.items():
        string = string.replace(var, val)
    return string


def is_comment(s):
    return s.startswith('#')


def do_request(block, buf):
    variables = dict((m.groups() for m in (GLOBAL_VAR_REGEX.match(l) for l in buf) if m))
    variables.update(dict((m.groups() for m in (VAR_REGEX.match(l) for l in block) if m)))

    block = [line for line in block if not is_comment(line) and line.strip() != '']

    if len(block) == 0:
        print 'Request was empty.'
        return

    method_url = block.pop(0)
    method_url_match = METHOD_REGEX.match(method_url)
    if not method_url_match:
        print 'Could not find method or URL!'
        return

    method, url = method_url_match.groups()
    url = replace_vars(url, variables)

    headers = {}
    while len(block) > 0:
        header_match = HEADER_REGEX.match(block[0])
        if header_match:
            block.pop(0)
            header_name, header_value = header_match.groups()
            headers[header_name] = replace_vars(header_value, variables)
        else:
            break

    data = [ replace_vars(l, variables) for l in block ]
    files = None
    if all([ '=' in l for l in data ]):
      # Form data: separate entries into data dict, and files dict
      key_value_pairs = dict([ l.split('=', 1) for l in data ])
      def to_file(expr):
        type, arg = FILE_REGEX.match(expr).groups()
        arg = arg.replace('\\(', '(').replace('\\)', ')')
        return open(arg, 'rb') if type == 'file' else (arg)

      files = dict(map(lambda (k,v): (k, to_file(v)), filter(lambda (k,v): FILE_REGEX.match(v), key_value_pairs.items())))
      data = dict(filter(lambda (k,v): not FILE_REGEX.match(v), key_value_pairs.items()))
    else:
      # Straight data: just send it off as a string.
      data = '\n'.join(data)

    response = requests.request(method, url, headers=headers, data=data, files=files)
    content_type = response.headers.get('Content-Type', '').split(';')[0]

    response_body = response.text
    if content_type == 'application/json':
        try:
            response_body = json.dumps(
                json.loads(response.text), sort_keys=True, indent=2,
                separators=(',', ': '),
                ensure_ascii=vim.eval('g:http_client_json_escape_utf')=='1')
        except ValueError:
            pass

    display = (
        response_body.split('\n') +
        ['', '// status code: %s' % response.status_code] +
        ['// %s: %s' % (k, v) for k, v in response.headers.items()]
    )

    return display, content_type


# Vim methods.

def vim_filetypes_by_content_type():
    return {
        'application/json': vim.eval('g:http_client_json_ft'),
        'application/xml': 'xml',
        'text/html': 'html'
    }

BUFFER_NAME = '__HTTP_Client_Response__'


def find_block(buf, line_num):
    length = len(buf)
    is_buffer_terminator = lambda s: s.strip() == ''

    block_start = line_num
    while block_start > 0 and not is_buffer_terminator(buf[block_start]):
        block_start -= 1

    block_end = line_num
    while block_end < length and not is_buffer_terminator(buf[block_end]):
        block_end += 1

    return buf[block_start:block_end + 1]


def open_scratch_buffer(contents, filetype):
    previous_window = vim.current.window
    existing_buffer_window_id = vim.eval('bufwinnr("%s")' % BUFFER_NAME)
    if existing_buffer_window_id == '-1':
        if vim.eval('g:http_client_result_vsplit') == '1':
            split_cmd = 'vsplit'
        else:
            split_cmd = 'split'
        vim.command('rightbelow %s %s' % (split_cmd, BUFFER_NAME))
        vim.command('setlocal buftype=nofile nospell')
    else:
        vim.command('%swincmd w' % existing_buffer_window_id)

    vim.command('set filetype=%s' % filetype)
    vim.current.buffer[:] = contents

    if vim.eval('g:http_client_focus_output_window') != '1':
        vim.current.window = previous_window


def do_request_from_buffer():
    win = vim.current.window
    line_num = win.cursor[0] - 1
    block = find_block(win.buffer, line_num)
    result = do_request(block, win.buffer)
    if result:
        response, content_type = result
        vim_ft = vim_filetypes_by_content_type().get(content_type, 'text')
        open_scratch_buffer(response, vim_ft)


# Tests.

def run_tests():
    import json

    def extract_json(resp):
        return json.loads(''.join([ l for l in resp[0] if not l.startswith('//') ]))

    def test(assertion, test):
        print 'Test %s: %s' % ('passed' if assertion else 'failed', test)
        if not assertion:
            raise AssertionError

    resp = extract_json(do_request([
        '# comment',
        '# :a=barf',
        'GET http://httpbin.org/headers',
        'X-Hey: :a',
        '# comment'
    ], []))
    test(resp['headers']['X-Hey'] == 'barf', 'Headers are passed with variable substitution.')

    resp = extract_json(do_request([
        '# :a = barf',
        'GET http://httpbin.org/get?data=:a'
    ], []))
    test(resp['args']['data'] == 'barf', 'GET data is passed with variable substitution.')

    resp = extract_json(do_request([
        'POST http://httpbin.org/post',
        'some data'
    ], []))
    test(resp['data'] == 'some data', 'POST data is passed with variable substitution.')

    resp = extract_json(do_request([
        'POST http://httpbin.org/post',
        'forma=a',
        'formb=b',
    ], []))
    test(resp['form']['forma'] == 'a', 'POST form data is passed.')

    resp = extract_json(do_request([
        'POST http://$global/post',
        'forma=a',
        'formb=b',
    ], [ '# $global = httpbin.org']))
    test(resp['form']['forma'] == 'a', 'Global variables are substituted.')

    import os
    from tempfile import NamedTemporaryFile

    SAMPLE_FILE_CONTENT = 'sample file content'

    temp_file = NamedTemporaryFile(delete = False)
    temp_file.write(SAMPLE_FILE_CONTENT)
    temp_file.close()
    resp = extract_json(do_request([
        'POST http://httpbin.org/post',
        'forma=a',
        'formb=b',
        "formc=!file(%s)" % temp_file.name,
    ], []))
    test(resp['files']['formc'] == SAMPLE_FILE_CONTENT, 'Files given as path are sent properly.')
    test(not 'formc' in resp['form'], 'File not included in form data.')
    os.unlink(temp_file.name)

    resp = extract_json(do_request([
        'POST http://httpbin.org/post',
        'forma=a',
        'formb=b',
        "formc=!content(%s)" % SAMPLE_FILE_CONTENT,
    ], []))
    test(resp['files']['formc'] == SAMPLE_FILE_CONTENT, 'Files given as content are sent properly.')

    resp = extract_json(do_request([
        'POST http://httpbin.org/post',
        "c=!content(foo \\(bar\\))",
    ], []))
    test(resp['files']['c'] == 'foo (bar)', 'Escaped parenthesis should be unescaped during request')


if from_cmdline:
    run_tests()
